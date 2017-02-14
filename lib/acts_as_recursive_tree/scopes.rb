module ActsAsRecursiveTree
  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :roots, -> { where(_recursive_tree_config.parent_key => nil) }

      scope :self_and_ancestors_of, ->(ids, opts = {}) {
        Builder::Ancestors.new(
            self,
            ids,
            opts.merge(
                exclude_ids: false
            )
        ).build
      }

      scope :ancestors_of, ->(ids, opts = {}) {
        Builder::Ancestors.new(
            self,
            ids,
            opts.merge(
                exclude_ids: true
            )
        ).build
      }

      scope :self_and_descendants_of, ->(ids, opts = {}) {
        Builder::Descendants.new(
            self,
            ids,
            opts.merge(
                exclude_ids: false
            )
        ).build
      }

      scope :descendants_of, ->(ids, opts = {}) {
        Builder::Descendants.new(
            self,
            ids,
            opts.merge(
                exclude_ids: true
            )
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
