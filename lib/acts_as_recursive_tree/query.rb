require 'active_support/concern'

module ActsAsRecursiveTree
  module Query
    extend ActiveSupport::Concern
    module ClassMethods

      ##
      # Selects all descendants/ancestors of this Location including it self OR
      # returns the related arel for more complicated database selects.
      #
      # Arel should look like this:
      #
      #   WITH RECURSIVE "traverse_loc" AS (
      #     SELECT * FROM "item_table"  WHERE "item_table"."id" = 25441
      #     UNION
      #     SELECT "item_table".* FROM "item_table"
      #     INNER JOIN "traverse_loc" ON "traverse_loc"."id" = "item_table"."parent_id"
      #   ) SELECT * FROM "traverse_loc"
      #
      # @param id [Integer] the id to start looking for related items
      # @param descendants [Boolean] Indicates type of related item_table (descendants or ancestors).
      # @param arel [Boolean] Indicates return type.
      #
      # @return [ActiveRecord::Relation/Arel::Node::Alias]
      def related_recursive_items(id, descendants: true, only_column: :id, stop_condition: nil)

        raise ArgumentError, 'id must not be nil' if id.nil?

        id         = id.id if id.is_a?(ActiveRecord::Base)
        item_table = self.arel_table

        traverse_loc = Arel::Table.new(:traverse_loc)

        base_select = build_base_select(item_table, id)

        recursive_relation = build_union_select(traverse_loc, item_table, descendants)
        recursive_relation = apply_stop_relation(recursive_relation, stop_condition)

        as_traverse_loc = build_as_travers_loc(traverse_loc, base_select, recursive_relation)

        query  = build_final_select(as_traverse_loc, traverse_loc, only_column)

        # return statement for where clause
        result = "\"#{self.table_name}\".\"id\" IN(#{query.to_sql})"

        result
      end

      ##
      # Creates a SelectManager for performing following code:
      #
      # SELECT id, parent_id FROM "item_table"  WHERE "item_table"."id" = 25441
      #
      # @param item_table [Arel::Table]
      # @param id [Integer]
      #
      # @return [Arel::SelectManager]
      #
      def build_base_select(item_table, id)

        base_select = Arel::SelectManager.new(ActiveRecord::Base)
        base_select.from(item_table)
            .project(item_table[Arel.star])
            .where(item_table[:id].eq(id))
        base_select
      end

      # SELECT "item_table".id, "item_table".parent_id FROM "item_table"
      # recursive_term = Arel::SelectManager.new(ActiveRecord::Base)
      # recursive_term.from(item_table)
      #   .project(item_table[Arel.star]) #.project(item_table[:id], item_table[fk])
      #
      # if descendants
      #   # INNER JOIN "traverse_loc" ON "traverse_loc"."id" = "item_table"."parent_id"
      #   on = traverse_loc[:id]
      #   eq = item_table[fk]
      # else
      #   # INNER JOIN "traverse_loc" ON "traverse_loc"."parent_id" = "item_table"."id"
      #   on = traverse_loc[fk]
      #   eq = item_table[:id]
      # end
      # recursive_term.join(traverse_loc).on(on.eq(eq))
      #
      # add_condition_relation(recursive_term, stop_condition) if stop_condition

      def build_union_select(travers_loc_table, item_table, descendants)
        from, to = if descendants
          [:id, recursive_tree_config[:foreign_key]]
        else
          [recursive_tree_config[:foreign_key], :id]
        end

        join_condition = 'INNER JOIN "'
        join_condition << travers_loc_table.name
        join_condition << '" ON "'
        join_condition << travers_loc_table.name
        join_condition << '"."'
        join_condition << from.to_s
        join_condition << '" = "'
        join_condition << item_table.name
        join_condition << '"."'
        join_condition << to.to_s
        join_condition << '"'

        recursive_tree_config[:base_class].constantize.joins(join_condition).unscope(:where)
      end

      ##
      #
      #
      def apply_stop_relation(base_relation, stop_relation)
        result = base_relation.merge(stop_relation) if stop_relation

        result || base_relation
      end

      # WITH RECURSIVE "traverse_loc" AS (
      #   base_select
      #   UNION
      #   recursive_term
      # )
      def build_as_travers_loc(traverse_loc, base_select, recursive_relation)
        Arel::Nodes::As.new(traverse_loc, base_select.union(recursive_relation.arel))
      end

      ##
      # SELECT * FROM "traverse_loc"
      #
      # @return [Arel::SelectManager]
      #
      def build_final_select(as_traverse_loc, traverse_loc, only_column)
        query = Arel::SelectManager.new(ActiveRecord::Base)
        query.with(:recursive, as_traverse_loc)
            .project(traverse_loc[only_column])
            .distinct
            .from(traverse_loc)
            .where(traverse_loc[only_column].not_eq(nil))
      end
    end
  end
end
