# frozen_string_literal: true

module ActsAsRecursiveTree
  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :roots, lambda {
        rel = where(_recursive_tree_config.parent_key => nil)
        if _recursive_tree_config.parent_type_column
          rel = rel.or(
            where.not(_recursive_tree_config.parent_type_column => to_s)
          )
        end

        rel
      }
    end
  end
end
