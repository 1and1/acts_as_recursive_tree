# frozen_string_literal: true

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

      attr_reader :klass, :ids, :recursive_temp_table, :travers_loc_table, :without_ids

      mattr_reader(:random) { Random.new }

      # Delegators for easier accessing config and query options
      delegate :primary_key, :depth_column, :parent_key, :parent_type_column, to: :@config
      delegate :depth_present?, :depth, :condition, :ensure_ordering, to: :@query_opts

      def initialize(klass, ids, exclude_ids: false, &block)
        @klass       = klass
        @config      = klass._recursive_tree_config
        @ids         = ActsAsRecursiveTree::Options::Values.create(ids, @config)
        @without_ids = exclude_ids

        @query_opts = get_query_options(block)

        rand_int              = random.rand(1_000_000)
        @recursive_temp_table = Arel::Table.new("recursive_#{klass.table_name}_#{rand_int}_temp")
        @travers_loc_table    = Arel::Table.new("traverse_#{rand_int}_loc")
      end

      #
      # Constructs a new QueryOptions and yield it to the proc if one is present.
      # Subclasses may override this method to provide sane defaults.
      #
      # @param proc [Proc] a proc or nil
      #
      # @return [ActsAsRecursiveTree::Options::QueryOptions] the new QueryOptions instance
      def get_query_options(proc)
        opts = ActsAsRecursiveTree::Options::QueryOptions.new

        proc&.call(opts)

        opts
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
        projections = if column
                        travers_loc_table[column]
                      else
                        Arel.star
                      end

        select_mgr = travers_loc_table.project(projections).with(:recursive, build_cte_table)

        apply_depth(select_mgr)
      end

      def build_cte_table
        Arel::Nodes::As.new(
          travers_loc_table,
          build_base_select.union(build_union_select)
        )
      end

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
