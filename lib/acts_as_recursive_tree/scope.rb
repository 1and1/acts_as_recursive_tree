module ActsAsRecursiveTree
  module Scope
    extend ActiveSupport::Concern

    included do
      scope :roots, -> { where(recursive_tree_config[:foreign_key] => nil) }

      scope :without, ->(record) {
        where.not(id: record.is_a?(ActiveRecord::Base) ? record.id : record)
      }

      scope :self_and_ancestors_of, ->(record) {
        where(related_recursive_items(record, descendants: false))
      }

      scope :ancestors_of, ->(record) {
        self_and_ancestors_of(record).without(record)
      }

      scope :self_and_descendants_of, ->(record) {
        where(related_recursive_items(record, descendants: true))
      }

      scope :descendants_of, ->(record) {
        self_and_descendants_of(record).without(record)
      }

      scope :leaves_of, ->(record) {
        self_and_descendants_of(record).where(related_recursive_items(
                                                record,
                                                descendants: true,
                                                negate:      true,
                                                only_column: recursive_tree_config[:foreign_key])
        )
      }

    end
  end
end
