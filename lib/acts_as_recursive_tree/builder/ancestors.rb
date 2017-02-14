module ActsAsRecursiveTree
  module Builder
    class Ancestors < Base

      def build_join_condition
        travers_loc_table[config.parent_key].eq(base_table[config.primary_key])
      end

      def build
        super.order("#{recursive_temp_table.name}.#{config.depth_column.to_s} ASC")
      end

    end
  end
end
