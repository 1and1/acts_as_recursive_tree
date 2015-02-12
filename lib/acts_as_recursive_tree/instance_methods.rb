module ActsAsRecursiveTree
  module InstanceMethods
    extend ActiveSupport::Concern

    included do


      ##
      # Selects all descendants/ancestors of this Location including it self OR
      # returns the related arel for more complicated database selects.
      #
      # Arel should look like this:
      #
      #   WITH RECURSIVE "traverse_loc" AS (
      #     SELECT * FROM "locations"  WHERE "locations"."id" = 25441
      #     UNION
      #     SELECT "locations".* FROM "locations"
      #     INNER JOIN "traverse_loc" ON "traverse_loc"."id" = "locations"."parent_id"
      #   ) SELECT * FROM "traverse_loc"
      #
      # @param clazz [Class] Target location class; only for ActiveRecord::Relations
      # @param descendants [Boolean] Indicates type of related locations (descendants or ancestors).
      # @param arel [Boolean] Indicates return type.
      #
      # @return [ActiveRecord::Relation/Arel::Node::Alias]
      def related_locations(clazz: nil, descendants: true, arel: false)
        locations    = self.class.arel_table
        traverse_loc = Arel::Table.new(:traverse_loc, ActiveRecord::Base)

        # SELECT * FROM "locations"  WHERE "locations"."id" = 25441
        base_select  = Arel::SelectManager.new(ActiveRecord::Base)
        base_select.from(locations).project(Arel.star).where(locations[:id].eq(self.id))

        # SELECT "locations".* FROM "locations"
        recursive_term = Arel::SelectManager.new(ActiveRecord::Base)
        recursive_term.from(locations).project(locations['*'])

        if descendants
          # INNER JOIN "traverse_loc" ON "traverse_loc"."id" = "locations"."parent_id"
          recursive_term.join(traverse_loc).on(traverse_loc[:id].eq locations[:parent_id])
        else
          # INNER JOIN "traverse_loc" ON "traverse_loc"."parent_id" = "locations"."id"
          recursive_term.join(traverse_loc).on(traverse_loc[:parent_id].eq locations[:id])
        end

        # WITH RECURSIVE "traverse_loc" AS (
        #   base_select
        #   UNION
        #   recursive_term
        # )
        as_traverse_loc = Arel::Nodes::As.new(traverse_loc, base_select.union(recursive_term))

        # SELECT * FROM "traverse_loc"
        query           = Arel::SelectManager.new(ActiveRecord::Base).with(:recursive, as_traverse_loc).
          project(Arel.star).from(traverse_loc)

        # return ActiveRecord::Relation if the arel is not requested
        unless arel
          clazz ||= Location
          # alias recursive statement as 'locations' to match ActiveRecord select
          clazz.from(query.as(Location.table_name).to_sql)
        else
          query
        end
      end


      ##
      # Returns list of ancestors, starting from parent until root.
      #
      # subchild1.ancestors # => [child1, root]
      def ancestors
        node, nodes = self, []
        nodes << node = node.parent while node.parent
        nodes
      end

      ##
      # Returns list of descendants, starting from current node, not including current node.
      #
      # root.descendants # => [child1, child2, subchild1, subchild2, subchild3, subchild4]
      def descendants
        children.each_with_object(children.to_a) { |child, arr|
          arr.concat child.descendants
        }.uniq
      end

      ##
      # Returns list of descendants, starting from current node, including current node.
      #
      # root.self_and_descendants # => [root, child1, child2, subchild1, subchild2, subchild3, subchild4]
      def self_and_descendants
        [self] + descendants
      end

      ##
      # Returns the root node of the tree.
      def root
        node = self
        node = node.parent while node.parent
        node
      end

      ##
      # Returns all siblings of the current node.
      #
      # subchild1.siblings # => [subchild2]
      def siblings
        self_and_siblings - [self]
      end

      ##
      # Returns all siblings and a reference to the current node.
      #
      # subchild1.self_and_siblings # => [subchild1, subchild2]
      def self_and_siblings
        parent ? parent.children : self.class.roots
      end

      ##
      # Returns children (without subchildren) and current node itself.
      #
      # root.self_and_children # => [root, child1]
      def self_and_children
        [self] + self.children
      end

      # Returns ancestors and current node itself.
      #
      # subchild1.self_and_ancestors # => [subchild1, child1, root]
      def self_and_ancestors
        [self] + self.ancestors
      end

      # Returns true if node has no parent, false otherwise
      #
      # subchild1.root? # => false
      # root.root? # => true
      def root?
        parent.nil?
      end

      # Returns true if node has no children, false otherwise
      #
      # subchild1.leaf? # => true
      # child1.leaf? # => false
      def leaf?
        children.size.zero?
      end

    end
  end
end