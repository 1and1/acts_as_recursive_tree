module ActsAsRecursiveTree
  module Builders
    module Strategy
      #
      # Build a relation using an INNER JOIN.
      #
      module Join
        #
        # Builds the relation.
        #
        # @param builder [ActsAsRecursiveTree::Builders::RelationBuilder]
        # @return [ActiveRecord::Relation]
        def self.build(builder)
          final_select_mgr = builder.base_table.join(
            builder.create_select_manger.as(builder.recursive_temp_table.name)
          ).on(
            builder.base_table[builder.primary_key].eq(builder.recursive_temp_table[builder.primary_key])
          )

          relation = builder.klass.joins(final_select_mgr.join_sources)

          relation = builder.apply_depth(relation)
          relation = builder.apply_order(relation)
          relation
        end
      end
    end
  end
end
