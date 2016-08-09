module ActsAsRecursiveTree
  module Scope
    extend ActiveSupport::Concern

    included do
      scope :roots, -> { where(recursive_tree_config[:foreign_key] => nil) }

      scope :without_record, ->(record) {
        where.not(id: record.is_a?(ActiveRecord::Base) ? record.id : record)
      }

      scope :self_and_ancestors_of, ->(record, condition = nil) {
        builder = recursive_query_builder(record)
        joins(
            builder.recursive_sql_for_join(
                type:            :ancestors,
                query_condition: condition
            )
        ).order(builder.recursive_depth_column)
      }

      scope :ancestors_of, ->(record, condition = nil) {
        self_and_ancestors_of(record, condition).without_record(record)
      }

      scope :self_and_descendants_of, ->(record, condition = nil) {
        joins(
            recursive_query_builder(record).recursive_sql_for_join(
                query_condition: condition
            )
        )
      }

      scope :descendants_of, ->(record, condition = nil) {
        self_and_descendants_of(record, condition).without_record(record)
      }

      scope :leaves_of, ->(record) {
        self_and_descendants_of(record).where.not(
            recursive_query_builder(record).recursive_sql_for_where(
                only_column: recursive_tree_config[:foreign_key]
            )
        )
      }

    end
  end
end
