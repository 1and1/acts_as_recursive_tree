module ActsAsRecursiveTree
  class RelationBuilder

    attr_reader :base_class, :ids, :base_table, :recursive_temp_table, :travers_loc_table, :config
    attr_reader :recursion_type, :query_condition, :only_leaves, :without_ids, :ordering
    mattr_reader(:random) { Random.new }

    def initialize(klass, ids, opts = {})
      @base_class = klass.base_class
      @config     = base_class._recursive_tree_config
      @ids        = Builder::Ids.create(ids, config)
      @base_table = base_class.arel_table

      rand_int              = random.rand(1_000_000)
      @recursive_temp_table = Arel::Table.new("recursive_#{base_class.table_name}_#{rand_int}_temp")
      @travers_loc_table    = Arel::Table.new("traverse_#{rand_int}_loc")

      set_opts(opts)
    end

    def set_opts(recursion_type: :descendants, condition: nil, only_leaves: false, exclude_ids: false, ordering: false)
      raise InvalidArgument, 'Only recursion_type :descendants is allowed when only_leaves is true' if only_leaves && recursion_type != :descendants

      @recursion_type  = recursion_type
      @query_condition = condition
      @only_leaves     = only_leaves
      @without_ids     = exclude_ids
      @ordering        = ordering
    end

    private :set_opts

    def build
      select_manager = travers_loc_table.project(Arel.star).with(:recursive, build_cte_table)
      apply_leaves_condition(select_manager) if only_leaves

      final_select_mgr = base_table.join(
          select_manager.as(recursive_temp_table.name)
      ).on(
          base_table[config.primary_key].eq(recursive_temp_table[config.primary_key])
      )

      relation = base_class.joins(final_select_mgr.join_sources)

      relation = relation.where(ids.apply_negated_to(base_table[config.primary_key])) if without_ids

      relation = relation.order("#{recursive_temp_table.name}.#{config.depth_column.to_s} ASC") if ordering
      relation
    end

    def apply_leaves_condition(select_manager)
      select_manager.where(
          travers_loc_table[config.primary_key].not_in(
              travers_loc_table.where(
                  travers_loc_table[config.parent_key].not_eq(nil)
              ).project(travers_loc_table[config.parent_key])
          )
      )
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
          Builder::RecursionDirection.for(recursion_type).build(base_table, travers_loc_table, config)
      )

      # need to use ActiveRecord here for merging relation
      relation        = base_class.select(
          base_table[config.primary_key],
          base_table[config.parent_key],
          Arel.sql(
              (travers_loc_table[config.depth_column] + 1).to_sql
          ).as(config.depth_column.to_s)
      ).unscope(where: :type).joins(select_manager.join_sources)

      relation        = relation.merge(query_condition) if query_condition
      relation.arel
    end

    def self.create_relation(klass, ids, opts = {})
      builder = self.new(klass, ids, opts)

      builder.build
    end


  end
end
