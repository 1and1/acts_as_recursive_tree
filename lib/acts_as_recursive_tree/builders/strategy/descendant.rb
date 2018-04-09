module ActsAsRecursiveTree
  module Builders
    module Strategy
      #
      # Strategy for building descendants relation
      #
      module Descendant
        #
        # Builds the relation
        #
        def self.build(builder)
          builder.base_table[builder.parent_key].eq(builder.travers_loc_table[builder.primary_key])
        end
      end
    end
  end
end
