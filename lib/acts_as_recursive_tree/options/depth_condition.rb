# frozen_string_literal: true

module ActsAsRecursiveTree
  module Options
    class DepthCondition
      def ==(other)
        @value     = Values.create(other)
        @operation = true
      end

      def !=(other)
        @value     = Values.create(other)
        @operation = false
      end

      def <(other)
        @value     = other
        @operation = :lt
      end

      def <=(other)
        @value     = other
        @operation = :lteq
      end

      def >(other)
        @value     = other
        @operation = :gt
      end

      def >=(other)
        @value     = other
        @operation = :gteq
      end

      def apply_to(attribute)
        if @value.is_a?(Values::Base)
          if @operation
            @value.apply_to(attribute)
          else
            @value.apply_negated_to(attribute)
          end
        else
          attribute.send(@operation, @value)
        end
      end
    end
  end
end
