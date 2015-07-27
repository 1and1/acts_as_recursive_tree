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
    def ancestors
      self.class.ancestors_of(self)
    end

    # Returns ancestors and current node itself.
    #
    # subchild1.self_and_ancestors # => [subchild1, child1, root]
    def self_and_ancestors
      self.class.self_and_ancestors_of(self)
    end

    ##
    # Returns list of descendants, starting from current node, not including current node.
    #
    # root.descendants # => [child1, child2, subchild1, subchild2, subchild3, subchild4]
    def descendants
      self.class.descendants_of(self)
    end

    ##
    # Returns list of descendants, starting from current node, including current node.
    #
    # root.self_and_descendants # => [root, child1, child2, subchild1, subchild2, subchild3, subchild4]
    def self_and_descendants
      self.class.self_and_descendants_of(self)
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
      self.class.where(self.recursive_tree_config[:foreign_key] => self.attributes[self.recursive_tree_config[:foreign_key].to_s])
    end

    ##
    # Returns children (without subchildren) and current node itself.
    #
    # root.self_and_children # => [root, child1]
    def self_and_children
      self.class.where("id = :id or #{self.recursive_tree_config[:foreign_key]} = :id", id: self.id)
    end

    def leaves
      self.class.leaves_of(self)
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
      scope.without(self)
    end

    module ClassMethods
      def class_name
        ancestors.first.name
      end
    end
  end
end
