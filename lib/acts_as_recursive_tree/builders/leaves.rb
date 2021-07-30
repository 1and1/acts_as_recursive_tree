# frozen_string_literal: true

module ActsAsRecursiveTree
  module Builders
    class Leaves < Descendants
      def create_select_manger(column = nil)
        select_manager = super

        select_manager.where(
          travers_loc_table[primary_key].not_in(
            travers_loc_table.where(
              travers_loc_table[parent_key].not_eq(nil)
            ).project(travers_loc_table[parent_key])
          )
        )
        select_manager
      end

      def get_query_options(_)
        # do not allow any custom options
        ActsAsRecursiveTree::Options::QueryOptions.new
      end
    end
  end
end
