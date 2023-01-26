# frozen_string_literal: true

module ActsAsRecursiveTree
  module Preloaders
    #
    # Preloads all descendants records for a given node and sets the parent and child associations on each record
    # based on the preloaded data. After this, calling #parent or #children will not trigger a database query.
    #
    class Descendants
      def initialize(node, includes: nil)
        @node       = node
        @parent_key = node._recursive_tree_config.parent_key
        @includes   = includes
      end

      def preload!
        apply_records(@node)
      end

      private

      def records
        @records ||= begin
          descendants = @node.descendants
          descendants = descendants.includes(*@includes) if @includes
          descendants.to_a
        end
      end

      def apply_records(parent_node)
        children = records.select { |child| child.send(@parent_key) == parent_node.id }

        parent_node.association(:children).target = children

        children.each do |child|
          child.association(:parent).target = parent_node
          apply_records(child)
        end
      end
    end
  end
end
