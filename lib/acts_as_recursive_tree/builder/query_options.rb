module ActsAsRecursiveTree
  module Builder
    class QueryOptions
      class Depth
        attr_reader :value, :operation

        def initialize(value=nil)
          if value
            @value     = Values::create(value)
            @operation = true
          end
        end

        def !=(value)
          @value     = Values::create(value)
          @operation = false
        end

        def <(value)
          @value     = value
          @operation = :lt
        end

        def <=(value)
          @value     = value
          @operation = :lteq
        end

        def >(value)
          @value     = value
          @operation = :gt
        end

        def >=(value)
          @value     = value
          @operation = :gteq
        end

        def apply_to(attribute)
          if value.is_a?(Values::Base)
            if operation
            value.apply_to(attribute)
            else
              value.apply_negated_to(attribute)
            end
          else
            attribute.send(operation, value)
          end
        end
      end

      attr_accessor :condition

      def depth=(value)
        @depth = Depth.new(value)
      end

      def depth
        @depth ||= Depth.new
      end

      def depth_present?
        @depth.present?
      end
    end
  end
end
