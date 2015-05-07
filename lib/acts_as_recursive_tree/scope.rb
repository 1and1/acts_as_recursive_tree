module ActsAsRecursiveTree
  module Scope
    extend ActiveSupport::Concern

    included do
      scope :roots, -> { where(recursive_tree_config[:foreign_key] => nil) }

      scope :without, ->(record) { where.not(id: record.id) }

      scope :ancestors_of, ->(record) {
        related_recursive_items(record, descendants: false)
      }

      scope :descendants_of, ->(record) {
        related_recursive_items(record)
      }

    end
  end
end
