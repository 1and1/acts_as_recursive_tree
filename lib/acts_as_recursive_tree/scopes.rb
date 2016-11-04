module ActsAsRecursiveTree
  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :roots, -> { where(_recursive_tree_config.parent_key => nil) }

      scope :self_and_ancestors_of, ->(ids, opts = {}) {
        _create_recursive_relation(
            ids,
            opts.merge(
                recursion_type: :ancestors,
                exclude_ids:    false,
                ordering:       true
            )
        )
      }

      scope :ancestors_of, ->(ids, opts = {}) {
        _create_recursive_relation(
            ids,
            opts.merge(
                recursion_type: :ancestors,
                exclude_ids:    true,
                ordering:       true
            )
        )
      }

      scope :self_and_descendants_of, ->(ids, opts = {}) {
        _create_recursive_relation(
            ids,
            opts.merge(
                exclude_ids: false
            )
        )
      }

      scope :descendants_of, ->(ids, opts = {}) {
        _create_recursive_relation(
            ids,
            opts.merge(
                exclude_ids: true
            )
        )
      }

      scope :leaves_of, ->(ids) {
        _create_recursive_relation(
            ids,
            only_leaves: true
        )
      }

    end
  end
end
