module ActsAsRecursiveTree
  module Builders
    module Strategy
      module Ancestor
        def self.build(builder)
          builder.travers_loc_table[builder.parent_key].eq(builder.base_table[builder.primary_key])
        end
      end
    end
  end
end
