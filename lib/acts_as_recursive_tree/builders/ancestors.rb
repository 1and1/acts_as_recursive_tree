module ActsAsRecursiveTree
  module Builders
    class Ancestors < RelationBuilder
      self.traversal_strategy = ActsAsRecursiveTree::Builders::Strategy::Ancestor

      def get_query_options(_)
        opts = super
        opts.ensure_ordering!
        opts
      end

    end
  end
end
