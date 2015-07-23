module ActsAsRecursiveTree
  module Scope
    extend ActiveSupport::Concern

    included do
      scope :roots, -> { where(recursive_tree_config[:foreign_key] => nil) }

      scope :without, ->(record) { where.not(id: record.is_a?(ActiveRecord::Base) ? record.id : record) }


      scope :self_and_ancestors_of, ->(record) {
        where("#{recursive_tree_config[:base_class].constantize.table_name}.id in(#{related_recursive_items(record, descendants: false, arel: true, only_id: true).to_sql})")
      }

      scope :ancestors_of, ->(record) {
        self_and_ancestors_of(record).without(record)
      }

      scope :self_and_descendants_of, ->(record) {
        where("#{recursive_tree_config[:base_class].constantize.table_name}.id in(#{related_recursive_items(record, arel: true, only_id: true).to_sql})")
      }

      scope :descendants_of, ->(record) {
        self_and_descendants_of(record).without(record)
      }

    end
  end
end
