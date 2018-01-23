module ActsAsRecursiveTree
  module Builders
    class Descendants < RelationBuilder
      def build_join_condition
        base_table[parent_key].eq(travers_loc_table[primary_key])
      end
    end
  end
end
