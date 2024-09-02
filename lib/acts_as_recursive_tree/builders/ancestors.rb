# frozen_string_literal: true

module ActsAsRecursiveTree
  module Builders
    class Ancestors < RelationBuilder
      self.traversal_strategy = ActsAsRecursiveTree::Builders::Strategies::Ancestor

      def get_query_options(&)
        opts = super
        opts.ensure_ordering!
        opts
      end
    end
  end
end
