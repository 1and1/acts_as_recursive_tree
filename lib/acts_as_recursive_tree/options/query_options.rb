module ActsAsRecursiveTree
  module Options
    class QueryOptions

      attr_accessor :condition
      attr_reader :ensure_ordering

      def depth
        @depth ||= DepthCondition.new
      end

      def ensure_ordering!
        @ensure_ordering = true
      end

      def depth_present?
        @depth.present?
      end
    end
  end
end
