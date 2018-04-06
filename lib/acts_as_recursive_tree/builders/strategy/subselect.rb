module ActsAsRecursiveTree
  module Builders
    module Strategy
      #
      # Strategy for building a relation using an WHERE ID IN(...).
      #
      module Subselect
        #
        # Builds the relation.
        #
        # @param builder [ActsAsRecursiveTree::Builders::RelationBuilder]
        # @return [ActiveRecord::Relation]
        def self.build(builder)
          builder.klass.where(
            builder.base_table[builder.primary_key].in(
              builder.create_select_manger(builder.primary_key)
            )
          )
        end
      end
    end
  end
end
