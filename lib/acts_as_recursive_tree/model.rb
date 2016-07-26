require 'active_support/concern'

module ActsAsRecursiveTree
  module Model
    extend ActiveSupport::Concern

    included do
      # hack to get the right classname
      recursive_tree_config[:base_class] = class_name
    end

    ##
    # Returns list of ancestors, starting from parent until root.
    #
    # subchild1.ancestors # => [child1, root]
    #
    # @param :recursive_condition [ActiveRecord::Relation]
    #         The recursion will stop when the condition is no longer met
    def ancestors(recursive_condition: nil)
      base_class.ancestors_of(self, recursive_condition)
    end

    # Returns ancestors and current node itself.
    #
    # subchild1.self_and_ancestors # => [subchild1, child1, root]
    #
    # @param :recursive_condition [ActiveRecord::Relation]
    #         The recursion will stop when the condition is no longer met
    def self_and_ancestors(recursive_condition: nil)
      base_class.self_and_ancestors_of(self, recursive_condition)
    end

    ##
    # Returns list of descendants, starting from current node, not including current node.
    #
    # root.descendants # => [child1, child2, subchild1, subchild2, subchild3, subchild4]
    #
    # @param :recursive_condition [ActiveRecord::Relation]
    #         The recursion will stop when the condition is no longer met
    def descendants(recursive_condition: nil)
      base_class.descendants_of(self, recursive_condition)
    end

    ##
    # Returns list of descendants, starting from current node, including current node.
    #
    # root.self_and_descendants # => [root, child1, child2, subchild1, subchild2, subchild3, subchild4]
    #
    # @param :recursive_condition [ActiveRecord::Relation]
    #         The recursion will stop when the condition is no longer met
    def self_and_descendants(recursive_condition: nil)
      base_class.self_and_descendants_of(self, recursive_condition)
    end

    ##
    # Returns the root node of the tree.
    def root
      self_and_ancestors.where(self.recursive_tree_config[:foreign_key] => nil).first
    end

    ##
    # Returns all siblings of the current node.
    #
    # subchild1.siblings # => [subchild2]
    def siblings
      without_self(self_and_siblings)
    end

    ##
    # Returns all siblings and a reference to the current node.
    #
    # subchild1.self_and_siblings # => [subchild1, subchild2]
    def self_and_siblings
      base_class.where(self.recursive_tree_config[:foreign_key] => self.attributes[self.recursive_tree_config[:foreign_key].to_s])
    end

    ##
    # Returns children (without subchildren) and current node itself.
    #
    # root.self_and_children # => [root, child1]
    def self_and_children
      base_class.where("id = :id or #{self.recursive_tree_config[:foreign_key]} = :id", id: self.id)
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
      parent.blank?
    end

    # Returns true if node has no children, false otherwise
    #
    # subchild1.leaf? # => true
    # child1.leaf? # => false
    def leaf?
      !children.any?
    end

    def without_self(scope)
      scope.without_record(self)
    end

    ##
    # Returns the Class object of the base class. This is needed for STI
    #
    def base_class
      self.class.recursive_tree_config[:base_class].constantize
    end

    module ClassMethods
      def class_name
        ancestors.first.name
      end
    end
  end
end
