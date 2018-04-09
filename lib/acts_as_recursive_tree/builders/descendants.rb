module ActsAsRecursiveTree
  module Builders
    class Descendants < RelationBuilder
      self.traversal_strategy = ActsAsRecursiveTree::Builders::Strategy::Descendant
    end
  end
end
