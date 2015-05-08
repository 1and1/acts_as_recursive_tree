module ActsAsRecursiveTree
  module Scope
    extend ActiveSupport::Concern

    included do
      scope :roots, -> { where(recursive_tree_config[:foreign_key] => nil) }

      scope :without, ->(record) { where.not(id: record.id) }

      scope :ancestors_of, ->(record) {
        where("physical_units.id in(#{related_recursive_items(record, descendants: false, arel: true, only_id: true).to_sql})")
      }

      scope :descendants_of, ->(record) {
        where("physical_units.id in(#{related_recursive_items(record, arel: true, only_id: true).to_sql})")
      }

    end
  end
end
