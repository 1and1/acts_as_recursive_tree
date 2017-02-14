module ActsAsRecursiveTree
  module Builder
    class QueryOptions
      attr_accessor :condition
      attr_reader :depth

      def initialize
        @depth = Depth.new
      end

      def depth=(value)
        @depth = Depth.new(value)
      end


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


        def is_set?
          value && operation
        end

        def apply_to(attribute)
          if value.is_a?(Values::Base)
            value.apply_to(attribute)
          else
            attribute.send(operation, value)
          end
        end
      end

    end
  end
end
