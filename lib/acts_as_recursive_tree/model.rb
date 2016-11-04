require 'active_support/concern'

module ActsAsRecursiveTree
  module Model
    extend ActiveSupport::Concern

    ##
    # Returns list of ancestors, starting from parent until root.
    #
    # subchild1.ancestors # => [child1, root]
    #
    # @param :recursive_condition [ActiveRecord::Relation]
    #         The recursion will stop when the condition is no longer met
    def ancestors(opts = {})
      base_class.ancestors_of(self, opts)
    end

    # Returns ancestors and current node itself.
    #
    # subchild1.self_and_ancestors # => [subchild1, child1, root]
    #
    # @param :recursive_condition [ActiveRecord::Relation]
    #         The recursion will stop when the condition is no longer met
    def self_and_ancestors(opts = {})
      base_class.self_and_ancestors_of(self, opts)
    end

    ##
    # Returns list of descendants, starting from current node, not including current node.
    #
    # root.descendants # => [child1, child2, subchild1, subchild2, subchild3, subchild4]
    #
    # @param :recursive_condition [ActiveRecord::Relation]
    #         The recursion will stop when the condition is no longer met
    def descendants(opts = {})
      base_class.descendants_of(self, opts)
    end

    ##
    # Returns list of descendants, starting from current node, including current node.
    #
    # root.self_and_descendants # => [root, child1, child2, subchild1, subchild2, subchild3, subchild4]
    #
    # @param :recursive_condition [ActiveRecord::Relation]
    #         The recursion will stop when the condition is no longer met
    def self_and_descendants(opts = {})
      base_class.self_and_descendants_of(self, opts)
    end

    ##
    # Returns the root node of the tree.
    def root
      self_and_ancestors.where(self._recursive_tree_config.parent_key => nil).first
    end

    ##
    # Returns all siblings of the current node.
    #
    # subchild1.siblings # => [subchild2]
    def siblings
      self_and_siblings.where.not(id: self.id)
    end

    ##
    # Returns children (without subchildren) and current node itself.
    #
    # root.self_and_children # => [root, child1]
    def self_and_children
      table = self.class.arel_table
      id    = self.attributes[self._recursive_tree_config.primary_key.to_s]

      base_class.where(
          table[self._recursive_tree_config.primary_key].eq(id).or(
              table[self._recursive_tree_config.parent_key].eq(id)
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
      self.attributes[self._recursive_tree_config.parent_key.to_s].blank?
    end

    # Returns true if node has no children, false otherwise
    #
    # subchild1.leaf? # => true
    # child1.leaf? # => false
    def leaf?
      !children.any?
    end

    def base_class
      self.class.base_class
    end
    private :base_class

    class_methods do
      ##
      # Returns a Relation instance for use in scopes.
      #
      # @return [ActiveRecord::Relation]
      #
      def _create_recursive_relation(ids, opts ={})
        RelationBuilder.create_relation(self, ids, opts)
      end
    end
  end
end
