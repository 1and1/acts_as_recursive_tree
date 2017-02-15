module ActsAsRecursiveTree
  module Builder
    class Base

      attr_reader :klass, :ids, :recursive_temp_table, :travers_loc_table
      attr_reader :query_opts, :without_ids
      mattr_reader(:random) { Random.new }

      def initialize(klass, ids, exclude_ids: false, proc: nil)
        @klass       = klass
        @ids         = Values.create(ids, config)
        @without_ids = exclude_ids

        @query_opts = QueryOptions.new

        proc.call(@query_opts) if proc

        rand_int              = random.rand(1_000_000)
        @recursive_temp_table = Arel::Table.new("recursive_#{klass.table_name}_#{rand_int}_temp")
        @travers_loc_table    = Arel::Table.new("traverse_#{rand_int}_loc")
      end

      def base_table
        klass.arel_table
      end

      def config
        klass._recursive_tree_config
      end

      def build
        final_select_mgr = base_table.join(
            create_select_manger.as(recursive_temp_table.name)
        ).on(
            base_table[config.primary_key].eq(recursive_temp_table[config.primary_key])
        )

        relation = klass.joins(final_select_mgr.join_sources)

        relation = apply_except_id(relation)
        relation = apply_depth(relation)

        relation
      end

      def apply_except_id(relation)
        return relation unless without_ids
        relation.where(ids.apply_negated_to(base_table[config.primary_key]))
      end

      def apply_depth(relation)
        return relation unless query_opts.depth_present?

        relation.where(query_opts.depth.apply_to(recursive_temp_table[config.depth_column]))
      end

      def create_select_manger
        travers_loc_table.project(Arel.star).with(:recursive, build_cte_table)
      end

      def build_cte_table
        Arel::Nodes::As.new(
            travers_loc_table,
            build_base_select.union(build_union_select)
        )
      end

      def build_base_select
        id_node = base_table[config.primary_key]

        base_table.where(
            ids.apply_to(id_node)
        ).project(
            id_node,
            base_table[config.parent_key],
            Arel.sql('0').as(config.depth_column.to_s)
        )
      end

      def build_union_select
        select_manager = base_table.join(travers_loc_table).on(
            build_join_condition
        )

        # need to use ActiveRecord here for merging relation
        relation       = klass.select(
            base_table[config.primary_key],
            base_table[config.parent_key],
            Arel.sql(
                (travers_loc_table[config.depth_column] + 1).to_sql
            ).as(config.depth_column.to_s)
        ).unscope(where: :type).joins(select_manager.join_sources)

        relation       = relation.merge(query_opts.condition) if query_opts.condition.present?
        relation.arel
      end

      def build_join_condition
        raise 'not implemented'
      end

    end
  end
end
