# frozen_string_literal: true

require 'active_support/concern'

module ActsAsRecursiveTree
  module Associations
    extend ActiveSupport::Concern

    included do
      belongs_to :parent,
                 class_name: base_class.to_s,
                 foreign_key: _recursive_tree_config.parent_key,
                 inverse_of: :children,
                 optional: true

      has_many :children,
               class_name: base_class.to_s,
               foreign_key: _recursive_tree_config.parent_key,
               inverse_of: :parent,
               dependent: _recursive_tree_config.dependent

      has_many :self_and_siblings,
               through: :parent,
               source: :children,
               class_name: base_class.to_s
    end
  end
end
