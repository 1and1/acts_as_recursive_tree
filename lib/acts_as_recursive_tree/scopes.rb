module ActsAsRecursiveTree
  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :roots, -> {
        rel = where(_recursive_tree_config.parent_key => nil)
        rel = rel.or(
          where.not(_recursive_tree_config.parent_type_column => self.to_s)
        ) if _recursive_tree_config.parent_type_column

        rel
      }
    end
  end
end
