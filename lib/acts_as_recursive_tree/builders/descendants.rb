# frozen_string_literal: true

module ActsAsRecursiveTree
  module Builders
    class Descendants < RelationBuilder
      self.traversal_strategy = ActsAsRecursiveTree::Builders::Strategies::Descendant
    end
  end
end
