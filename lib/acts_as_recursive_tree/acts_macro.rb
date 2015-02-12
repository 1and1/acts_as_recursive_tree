module ActsAsRecursiveTree
  module ActsMacro

    ##
    # Configuration options are:
    #
    # * <tt>foreign_key</tt> - specifies the column name to use for tracking
    # of the tree (default: +parent_id+)
    # * <tt>order</tt> - makes it possible to sort the children according to
    # this SQL snippet.
    # * <tt>counter_cache</tt> - keeps a count in a +children_count+ column
    # if set to +true+ (default: +false+). Specify
    # a custom column by passing a symbol or string.
    def acts_as_tree(options = {})

      configuration = {
        foreign_key: 'parent_id',
        dependent:   :destroy
      }

      configuration.update(options) if options.is_a?(Hash)

      class_attribute :acts_as_tree_config
      self.acts_as_tree_config = configuration

      include ActsAsRecursiveTree::ClassMethods
      include ActsAsRecursiveTree::InstanceMethods
    end
  end
end