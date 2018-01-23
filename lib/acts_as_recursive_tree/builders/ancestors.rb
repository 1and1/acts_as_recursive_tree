module ActsAsRecursiveTree
  module Builders
    class Ancestors < RelationBuilder

      def build_join_condition
        travers_loc_table[parent_key].eq(base_table[primary_key])
      end

      def get_query_options(_)
        opts = super
        opts.ensure_ordering!
        opts
      end

    end
  end
end
