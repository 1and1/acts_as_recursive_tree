module ActsAsRecursiveTree
  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :roots, -> { where(_recursive_tree_config.parent_key => nil) }

      scope :self_and_ancestors_of, ->(ids, proc = nil) {
        Builder::Ancestors.new(
            self,
            ids,
            proc: proc
        ).build
      }

      scope :ancestors_of, ->(ids, proc = nil) {
        Builder::Ancestors.new(
            self,
            ids,
            exclude_ids: true,
            proc:        proc

        ).build
      }

      scope :self_and_descendants_of, ->(ids, proc = nil) {
        Builder::Descendants.new(
            self,
            ids,
            proc: proc
        ).build
      }

      scope :descendants_of, ->(ids, proc = nil) {
        Builder::Descendants.new(
            self,
            ids,
            exclude_ids: true,
            proc:        proc
        ).build
      }

      scope :leaves_of, ->(ids) {
        Builder::Leaves.new(
            self,
            ids
        ).build
      }

    end
  end
end
