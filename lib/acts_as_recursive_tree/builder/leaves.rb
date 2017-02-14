module ActsAsRecursiveTree
  module Builder
    class Leaves < Descendants

      def create_select_manger
        select_manager = super

        select_manager.where(
            travers_loc_table[config.primary_key].not_in(
                travers_loc_table.where(
                    travers_loc_table[config.parent_key].not_eq(nil)
                ).project(travers_loc_table[config.parent_key])
            )
        )
        select_manager

      end

    end
  end
end
