module ActsAsRecursiveTree
  module Query
    extend ActiveSupport::Concern

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
    # @param clazz [Class] Target location class; only for ActiveRecord::Relations
    # @param descendants [Boolean] Indicates type of related item_table (descendants or ancestors).
    # @param arel [Boolean] Indicates return type.
    #
    # @return [ActiveRecord::Relation/Arel::Node::Alias]
    def related_items(clazz: nil, descendants: true, arel: false)
      self.class.related_recursive_items(self.id, clazz: clazz, descendants: descendants, arel: arel)
    end

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
      # @param clazz [Class] Target location class; only for ActiveRecord::Relations
      # @param descendants [Boolean] Indicates type of related item_table (descendants or ancestors).
      # @param arel [Boolean] Indicates return type.
      #
      # @return [ActiveRecord::Relation/Arel::Node::Alias]
      def related_recursive_items(id, clazz: nil, descendants: true, arel: false, only_id: false)

        raise ArgumentError, 'id must not be nil' if id.nil?

        id = id.id if id.is_a?(ActiveRecord::Base)

        item_table   = self.arel_table
        traverse_loc = Arel::Table.new(:traverse_loc, ActiveRecord::Base)

        # SELECT * FROM "item_table"  WHERE "item_table"."id" = 25441
        base_select  = Arel::SelectManager.new(ActiveRecord::Base)
        base_select.from(item_table).project(Arel.star).where(item_table[:id].eq(id))

        # SELECT "item_table".* FROM "item_table"
        recursive_term = Arel::SelectManager.new(ActiveRecord::Base)
        recursive_term.from(item_table).project(item_table[Arel.star])

        if descendants
          # INNER JOIN "traverse_loc" ON "traverse_loc"."id" = "item_table"."parent_id"
          recursive_term.join(traverse_loc).on(traverse_loc[:id].eq(item_table[recursive_tree_config[:foreign_key]]))
        else
          # INNER JOIN "traverse_loc" ON "traverse_loc"."parent_id" = "item_table"."id"
          recursive_term.join(traverse_loc).on(traverse_loc[recursive_tree_config[:foreign_key]].eq(item_table[:id]))
        end

        # WITH RECURSIVE "traverse_loc" AS (
        #   base_select
        #   UNION
        #   recursive_term
        # )
        as_traverse_loc = Arel::Nodes::As.new(traverse_loc, base_select.union(recursive_term))

        # SELECT * FROM "traverse_loc"
        query           = Arel::SelectManager.new(ActiveRecord::Base).with(:recursive, as_traverse_loc).project(only_id ? traverse_loc[:id] : Arel.star).from(traverse_loc)

        # return ActiveRecord::Relation if the arel is not requested
        if arel
          query
        else
          sql_query =query.as(recursive_tree_config[:base_class].constantize.table_name).to_sql

          clazz ||= recursive_tree_config[:base_class].constantize
          # alias recursive statement as 'item_table' to match ActiveRecord select
          clazz.from(sql_query)
        end
      end
    end
  end
end