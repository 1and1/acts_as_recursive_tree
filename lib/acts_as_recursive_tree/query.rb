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
      def related_recursive_items(id, descendants: true, only_column: :id, negate: false)

        raise ArgumentError, 'id must not be nil' if id.nil?

        id = id.id if id.is_a?(ActiveRecord::Base)

        fk         = recursive_tree_config[:foreign_key]
        item_table = self.arel_table

        traverse_loc = Arel::Table.new(:traverse_loc, ActiveRecord::Base)

        # SELECT id, parent_id FROM "item_table"  WHERE "item_table"."id" = 25441
        base_select  = Arel::SelectManager.new(ActiveRecord::Base)
        base_select.from(item_table)
          .project(item_table[:id], item_table[fk])
          .where(item_table[:id].eq(id))

        # SELECT "item_table".id, "item_table".parent_id FROM "item_table"
        recursive_term = Arel::SelectManager.new(ActiveRecord::Base)
        recursive_term.from(item_table)
          .project(item_table[:id], item_table[fk])

        if descendants
          # INNER JOIN "traverse_loc" ON "traverse_loc"."id" = "item_table"."parent_id"
          on = traverse_loc[:id]
          eq = item_table[fk]
        else
          # INNER JOIN "traverse_loc" ON "traverse_loc"."parent_id" = "item_table"."id"
          on = traverse_loc[fk]
          eq = item_table[:id]
        end
        recursive_term.join(traverse_loc).on(on.eq(eq))

        # WITH RECURSIVE "traverse_loc" AS (
        #   base_select
        #   UNION
        #   recursive_term
        # )
        as_traverse_loc = Arel::Nodes::As.new(traverse_loc, base_select.union(recursive_term))

        # SELECT * FROM "traverse_loc"
        query           = Arel::SelectManager.new(ActiveRecord::Base)
        query.with(:recursive, as_traverse_loc)
          .project(traverse_loc[only_column])
          .distinct
          .from(traverse_loc)
          .where(traverse_loc[only_column].not_eq(nil))

        # return statement for where clause
        "\"#{self.table_name}\".id #{negate ? 'NOT' : ''} IN(#{query.to_sql})"
      end

    end
  end
end
