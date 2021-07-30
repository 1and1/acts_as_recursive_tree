# frozen_string_literal: true

module ActsAsRecursiveTree
  module Builders
    module Strategy
      #
      # Strategy for building ancestors relation
      #
      module Ancestor
        #
        # Builds the relation
        #
        def self.build(builder)
          builder.travers_loc_table[builder.parent_key].eq(builder.base_table[builder.primary_key])
        end
      end
    end
  end
end
