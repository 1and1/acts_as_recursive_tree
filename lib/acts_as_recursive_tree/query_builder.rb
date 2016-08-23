module ActsAsRecursiveTree
  class QueryBuilder
    TRAVERS_LOC = 'traverse_loc'
    attr_reader :base_class, :ids

    delegate :table_name, :recursive_tree_config, to: :base_class

    ##
    #
    # @param klass [Class<ActiveRecord::Base>]
    # @param ids [Integer|ActiveRecord::Base|Array<Integer>]
    #
    def initialize(klass, ids)
      @base_class = klass.base_class
      @ids        = ids.is_a?(ActiveRecord::Base) ? ids.id : ids
    end

    ##
    # @return [String] the temp table name when used in join clauses
    #
    def temp_table_name
      "recursive_#{table_name}_temp"
    end

    ##
    # @return [String] temp_table_name.field of the depth
    #
    def recursive_depth_column
      "#{quote(temp_table_name)}.#{quote(recursive_tree_config[:depth_column])}"
    end

    ##
    # Surrounds the given string with ""
    # @param string [String]
    #
    def quote(string)
      "\"#{string}\""
    end

    ##
    # Builds a SQL String that can be used in an ActiveRecord::Query::join clause.
    #
    # @param :type [Symbol] optional recursion type. One of :descendants or :ancestors. Defaults to :descendants.
    # @param :query_condition [ActiveRecord::Relation] optional relation parameter.
    # Only items that match the relation are considered during recursion.
    #
    # @return [String] the complete SQL statement
    #
    def recursive_sql_for_join(type: :descendants, query_condition: nil)
      recursive_sql = build_recursive_term_sql(type, query_condition)
      "INNER JOIN (#{recursive_sql}) AS #{temp_table_name} ON #{quote(table_name)}.#{quote(:id)} = #{temp_table_name}.#{quote(:id)}"
    end


    ##
    # Builds a SQL String that can be used in an ActiveRecord::Query::where clause.
    #
    # @param :type [Symbol] optional recursion type. One of :descendants or :ancestors. Defaults to :descendants.
    # @param :only_column [Symbol] optional column name to select. Defaults to :id
    # @param :query_condition [ActiveRecord::Relation] optional relation parameter.
    # Only items that match the relation are considered during recursion.
    #
    # @return [String] the complete SQL statement
    #
    def recursive_sql_for_where(type: :descendants, only_column: :id, query_condition: nil)
      recursive_sql = build_recursive_term_sql(type, query_condition, only_column)
      "#{quote(table_name)}.#{quote(:id)} IN (#{recursive_sql})"
    end

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
    # @param type [Symbol] optional recursion type. One of :descendants or :ancestors. Defaults to :descendants.
    # @param result_field [Symbol] optional column name to select
    # @param query_condition [ActiveRecord::Relation] optional relation parameter.
    #
    # @return [String] the complete SQL statement
    #
    def build_recursive_term_sql(type, query_condition, result_field = nil)

      fields = result_field ? "DISTINCT #{quote(TRAVERS_LOC)}.#{quote(result_field)}" : '*'

      parts = [
          "WITH RECURSIVE #{quote(TRAVERS_LOC)} AS (",
          base_select_sql,
          'UNION',
          build_recursive_sql(type, query_condition),
          ')',
          'SELECT',
          fields,
          'FROM',
          quote(TRAVERS_LOC)
      ]

      parts << "WHERE #{quote(TRAVERS_LOC)}.#{quote(result_field)} IS NOT NULL" if result_field

      parts.join(' ')
    end

    ##
    # Creates a sql string for performing following code:
    #
    # SELECT * FROM "item_table"  WHERE "item_table"."id" = 25441
    #
    # @return [String] the sql
    #
    def base_select_sql
      raise ArgumentError, 'id must not be nil' if ids.nil?

      base_class_select.select(
          "0 AS #{recursive_tree_config[:depth_column]}"
      ).where(id: ids).to_sql
    end

    ##
    # Creates a Base Relation with for selecting from the base_class table.
    #
    # @return [ActiveRecord::Relation]
    #
    def base_class_select
      # unscoping is necessary because this may be called from a Subtype class
      # where AR will automatically add the where condition.
      base_class.select("#{quote(table_name)}.*").unscope(where: :type)
    end


    ##
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
    # @param type [Symbol] optional recursion type. One of :descendants or :ancestors. Defaults to :descendants.
    # @param query_condition [ActiveRecord::Relation] optional relation parameter.
    #
    # @return [String] the complete SQL statement
    #
    def build_recursive_sql(type, query_condition)
      relation = base_class_select.joins(
          build_join_condition_sql(type)
      ).select(
          "#{quote(TRAVERS_LOC)}.#{quote(recursive_tree_config[:depth_column])} + 1 AS #{recursive_tree_config[:depth_column]}"
      )

      # apply stop relation
      relation = relation.merge(query_condition) if query_condition

      relation.to_sql
    end

    ##
    #
    # @param type [Symbol] One of :descendants or :ancestors
    #
    # @return [String] the complete SQL statement
    #
    def build_join_condition_sql(type)
      from, to = case type
      when :descendants
        [:id, recursive_tree_config[:foreign_key]]
      when :ancestors
        [recursive_tree_config[:foreign_key], :id]
      else
        raise "Invalid type #{type}! Only :descendants or :ancestors is allowed"
      end

      parts = [
          'INNER JOIN',
          quote(TRAVERS_LOC),
          'ON',
          "#{quote(TRAVERS_LOC)}.#{quote(from)}",
          '=',
          "#{quote(table_name)}.#{quote(to)}"
      ]

      parts.join(' ')
    end

  end
end
