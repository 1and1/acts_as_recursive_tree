module ActsAsRecursiveTree
  module Builders
    class Ancestors < RelationBuilder

      def build_join_condition
        travers_loc_table[config.parent_key].eq(base_table[config.primary_key])
      end

      def get_query_options(proc)
        opts                 = super
        opts.ensure_ordering = true
        opts
      end

    end
  end
end
