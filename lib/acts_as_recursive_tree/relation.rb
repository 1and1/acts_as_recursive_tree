require 'active_support/concern'

module ActsAsRecursiveTree
  module Relation
    extend ActiveSupport::Concern

    included do
      belongs_to :parent,
                 class_name:  self.base_class.to_s,
                 foreign_key: self.recursive_tree_config[:foreign_key],
                 inverse_of:  :children

      has_many :children,
               class_name:  self.base_class.to_s,
               foreign_key: self.recursive_tree_config[:foreign_key],
               inverse_of:  :parent

    end
  end
end
