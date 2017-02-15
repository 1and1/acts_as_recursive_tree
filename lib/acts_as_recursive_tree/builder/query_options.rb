module ActsAsRecursiveTree
  module Builder
    class QueryOptions
      class Depth
        attr_reader :value, :operation

        def initialize(value=nil)
          if value
            @value     = Values::create(value)
            @operation = :lt
          end
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
            value.apply_to(attribute)
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
