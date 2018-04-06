module ActsAsRecursiveTree
  module Builders
    module Strategy
      module Subselect
        def self.build(builder)

          relation = builder.klass.where(
            builder.base_table[builder.primary_key].in(
              builder.create_select_manger(builder.primary_key)
            )
          )

          relation
        end
      end
    end
  end
end
