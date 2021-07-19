module ActsAsRecursiveTree
  module Options
    module Values
      class Base
        attr_reader :value, :config

        def initialize(value, config)
          @value  = value
          @config = config
        end

        def prepared_value
          value
        end

        def apply_to(attribute)

        end

        def apply_negated_to(attribute)

        end
      end

      class SingleValue < Base
        def apply_to(attribute)
          attribute.eq(prepared_value)
        end

        def apply_negated_to(attribute)
          attribute.not_eq(prepared_value)
        end
      end

      class ActiveRecord < SingleValue
        def prepared_value
          value.id
        end
      end

      class RangeValue < Base
        def apply_to(attribute)
          attribute.between(prepared_value)
        end

        def apply_negated_to(attribute)
          attribute.not_between(prepared_value)
        end
      end

      class MultiValue < Base
        def apply_to(attribute)
          attribute.in(prepared_value)
        end

        def apply_negated_to(attribute)
          attribute.not_in(prepared_value)
        end
      end

      class Relation < MultiValue
        def prepared_value
          select_manager = value.arel
          select_manager.projections.clear
          select_manager.project(select_manager.froms.last[config.primary_key])
        end
      end

      def self.create(value, config = nil)
        klass = case value
        when ::Numeric, ::String
          SingleValue
        when ::ActiveRecord::Relation
          Relation
        when Range
          RangeValue
        when Enumerable
          MultiValue
        when ::ActiveRecord::Base
          ActiveRecord
        else
          raise "#{value.class} is not supported"
        end

        klass.new(value, config)
      end
    end
  end
end
