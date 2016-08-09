module ActsAsRecursiveTree
  module ActsMacro

    ##
    # Configuration options are:
    #
    # * <tt>foreign_key</tt> - specifies the column name to use for tracking
    # of the tree (default: +parent_id+)
    def recursive_tree(options = {})

      configuration = {
          foreign_key:  :parent_id,
          depth_column: :recursive_depth
      }

      configuration.update(options) if options.is_a?(Hash)

      class_attribute :recursive_tree_config
      self.recursive_tree_config = configuration

      include ActsAsRecursiveTree::Model
      include ActsAsRecursiveTree::Relation
      include ActsAsRecursiveTree::Scope
    end

    alias_method :acts_as_tree, :recursive_tree
  end
end