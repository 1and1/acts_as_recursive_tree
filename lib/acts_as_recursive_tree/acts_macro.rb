# frozen_string_literal: true

module ActsAsRecursiveTree
  module ActsMacro
    ##
    # Configuration options are:
    #
    # * <tt>foreign_key</tt> - specifies the column name to use for tracking
    # of the tree (default: +parent_id+)
    def recursive_tree(parent_key: :parent_id, parent_type_column: nil, dependent: nil)
      class_attribute(:_recursive_tree_config, instance_writer: false)

      self._recursive_tree_config = Config.new(
        model_class: self,
        parent_key: parent_key.to_sym,
        parent_type_column: parent_type_column.try(:to_sym),
        dependent: dependent
      )

      include ActsAsRecursiveTree::Model
      include ActsAsRecursiveTree::Associations
      include ActsAsRecursiveTree::Scopes
    end

    alias acts_as_tree recursive_tree
  end
end
