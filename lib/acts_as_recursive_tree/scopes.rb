module ActsAsRecursiveTree
  module Scopes
    extend ActiveSupport::Concern
    include ActsAsRecursiveTree::Builders

    included do
      scope :roots, -> {
        rel = where(_recursive_tree_config.parent_key => nil)
        rel = rel.or(
          where.not(_recursive_tree_config.parent_type_column => self.to_s)
        ) if _recursive_tree_config.parent_type_column

        rel
      }

      scope :self_and_ancestors_of, -> (ids, proc = nil) {
        Builders::Ancestors.new(
          self,
          ids,
          proc: proc
        ).build
      }

      scope :ancestors_of, ->(ids, proc = nil) {
        Ancestors.new(
          self,
          ids,
          exclude_ids: true,
          proc:        proc

        ).build
      }

      scope :self_and_descendants_of, ->(ids, proc = nil) {
        Descendants.new(
          self,
          ids,
          proc: proc
        ).build
      }

      scope :descendants_of, ->(ids, proc = nil) {
        Descendants.new(
          self,
          ids,
          exclude_ids: true,
          proc:        proc
        ).build
      }

      scope :leaves_of, ->(ids) {
        Leaves.new(
          self,
          ids
        ).build
      }

    end
  end
end
