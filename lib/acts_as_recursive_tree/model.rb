# frozen_string_literal: true

module ActsAsRecursiveTree
  module Model
    extend ActiveSupport::Concern

    ##
    # Returns list of ancestors, starting from parent until root.
    #
    # subchild1.ancestors # => [child1, root]
    #
    def ancestors(&block)
      base_class.ancestors_of(self, &block)
    end

    # Returns ancestors and current node itself.
    #
    # subchild1.self_and_ancestors # => [subchild1, child1, root]
    #
    def self_and_ancestors(&block)
      base_class.self_and_ancestors_of(self, &block)
    end

    ##
    # Returns list of descendants, starting from current node, not including current node.
    #
    # root.descendants # => [child1, child2, subchild1, subchild2, subchild3, subchild4]
    #
    def descendants(&block)
      base_class.descendants_of(self, &block)
    end

    ##
    # Returns list of descendants, starting from current node, including current node.
    #
    # root.self_and_descendants # => [root, child1, child2, subchild1, subchild2, subchild3, subchild4]
    #
    def self_and_descendants(&block)
      base_class.self_and_descendants_of(self, &block)
    end

    ##
    # Returns the root node of the tree.
    def root
      self_and_ancestors.where(_recursive_tree_config.parent_key => nil).first
    end

    ##
    # Returns all siblings of the current node.
    #
    # subchild1.siblings # => [subchild2]
    def siblings
      self_and_siblings.where.not(id: id)
    end

    ##
    # Returns children (without subchildren) and current node itself.
    #
    # root.self_and_children # => [root, child1]
    def self_and_children
      table = self.class.arel_table
      id    = attributes[_recursive_tree_config.primary_key.to_s]

      base_class.where(
        table[_recursive_tree_config.primary_key].eq(id).or(
          table[_recursive_tree_config.parent_key].eq(id)
        )
      )
    end

    ##
    # Returns all Leaves
    #
    def leaves
      base_class.leaves_of(self)
    end

    # Returns true if node has no parent, false otherwise
    #
    # subchild1.root? # => false
    # root.root? # => true
    def root?
      attributes[_recursive_tree_config.parent_key.to_s].blank?
    end

    # Returns true if node has no children, false otherwise
    #
    # subchild1.leaf? # => true
    # child1.leaf? # => false
    def leaf?
      children.none?
    end

    def base_class
      self.class.base_class
    end

    private :base_class

    module ClassMethods
      def self_and_ancestors_of(ids, &block)
        Builders::Ancestors.build(self, ids, &block)
      end

      def ancestors_of(ids, &block)
        Builders::Ancestors.build(self, ids, exclude_ids: true, &block)
      end

      def roots_of(ids)
        self_and_ancestors_of(ids).roots
      end

      def self_and_descendants_of(ids, &block)
        Builders::Descendants.build(self, ids, &block)
      end

      def descendants_of(ids, &block)
        Builders::Descendants.build(self, ids, exclude_ids: true, &block)
      end

      def leaves_of(ids, &block)
        Builders::Leaves.build(self, ids, &block)
      end
    end
  end
end
