require 'active_support/concern'

module ActsAsRecursiveTree
  module Relation
    extend ActiveSupport::Concern

    included do
      belongs_to :parent,
                 class_name:  self.recursive_tree_config[:base_class],
                 foreign_key: self.recursive_tree_config[:foreign_key],
                 inverse_of:  :children

      has_many :children,
               class_name:  self.recursive_tree_config[:base_class],
               foreign_key: self.recursive_tree_config[:foreign_key],
               inverse_of:  :parent

    end
  end
end
