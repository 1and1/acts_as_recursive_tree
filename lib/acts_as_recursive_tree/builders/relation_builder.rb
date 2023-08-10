# frozen_string_literal: true

require 'securerandom'

module ActsAsRecursiveTree
  module Builders
    #
    # Constructs the Arel necessary for recursion.
    #
    class RelationBuilder
      def self.build(klass, ids, exclude_ids: false, &block)
        new(klass, ids, exclude_ids: exclude_ids, &block).build
      end

      class_attribute :traversal_strategy, instance_writer: false

      attr_reader :klass, :ids, :without_ids

      # Delegators for easier accessing config and query options
      delegate :primary_key, :depth_column, :parent_key, :parent_type_column, to: :config
      delegate :depth_present?, :depth, :condition, :ensure_ordering, to: :@query_opts

      def initialize(klass, ids, exclude_ids: false, &block)
        @klass       = klass
        @ids         = ActsAsRecursiveTree::Options::Values.create(ids, klass._recursive_tree_config)
        @without_ids = exclude_ids

        @query_opts = get_query_options(&block)

        # random seed for the temp tables
        @rand_int = SecureRandom.rand(1_000_000)
      end

      def recursive_temp_table
        @recursive_temp_table ||= Arel::Table.new("recursive_#{klass.table_name}_#{@rand_int}_temp")
      end

      def travers_loc_table
        @travers_loc_table ||= Arel::Table.new("traverse_#{@rand_int}_loc")
      end

      def config
        klass._recursive_tree_config
      end

      #
      # Constructs a new QueryOptions and yield it to the proc if one is present.
      # Subclasses may override this method to provide sane defaults.
      #
      # @return [ActsAsRecursiveTree::Options::QueryOptions] the new QueryOptions instance
      def get_query_options(&block)
        ActsAsRecursiveTree::Options::QueryOptions.from(&block)
      end

      def base_table
        klass.arel_table
      end

      def build
        relation = Strategies.for_query_options(@query_opts).build(self)

        apply_except_id(relation)
      end

      def apply_except_id(relation)
        return relation unless without_ids

        relation.where(ids.apply_negated_to(base_table[primary_key]))
      end

      def apply_depth(select_manager)
        return select_manager unless depth_present?

        select_manager.where(depth.apply_to(travers_loc_table[depth_column]))
      end

      def create_select_manger(column = nil)
        projections = column ? travers_loc_table[column] : Arel.star

        select_mgr = travers_loc_table.project(projections).with(:recursive, build_cte_table)

        apply_depth(select_mgr)
      end

      def build_cte_table
        Arel::Nodes::As.new(
          travers_loc_table,
          add_pg_cycle_detection(
            build_base_select.union(build_union_select)
          )
        )
      end

      def add_pg_cycle_detection(union_query)
        return union_query unless config.cycle_detection?

        Arel::Nodes::InfixOperation.new(
          '',
          union_query,
          Arel.sql("CYCLE #{primary_key} SET is_cycle USING path")
        )
      end

      # Builds SQL:
      # SELECT id, parent_id, 0 AS depth FROM base_table WHERE id = 123
      def build_base_select
        id_node = base_table[primary_key]

        base_table.where(
          ids.apply_to(id_node)
        ).project(
          id_node,
          base_table[parent_key],
          Arel.sql('0').as(depth_column.to_s)
        )
      end

      def build_union_select
        join_condition = apply_parent_type_column(
          traversal_strategy.build(self)
        )

        select_manager = base_table.join(travers_loc_table).on(join_condition)

        # need to use ActiveRecord here for merging relation
        relation = build_base_join_select(select_manager)

        relation = apply_query_opts_condition(relation)
        relation.arel
      end

      def apply_parent_type_column(arel_condition)
        return arel_condition if parent_type_column.blank?

        arel_condition.and(base_table[parent_type_column].eq(klass.base_class))
      end

      def build_base_join_select(select_manager)
        klass.select(
          base_table[primary_key],
          base_table[parent_key],
          Arel.sql(
            (travers_loc_table[depth_column] + 1).to_sql
          ).as(depth_column.to_s)
        ).unscope(where: :type).joins(select_manager.join_sources)
      end

      def apply_query_opts_condition(relation)
        # check with nil? and not #present?/#blank? which will execute the query
        return relation if condition.nil?

        relation.merge(condition)
      end
    end
  end
end
