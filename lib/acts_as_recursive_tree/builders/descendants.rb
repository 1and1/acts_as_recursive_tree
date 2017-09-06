module ActsAsRecursiveTree
  module Builders
    class Descendants < RelationBuilder
      def build_join_condition
        base_table[config.parent_key].eq(travers_loc_table[config.primary_key])
      end
    end
  end
end
