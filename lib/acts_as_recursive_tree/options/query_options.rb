module ActsAsRecursiveTree
  module Options
    class QueryOptions

      attr_accessor :condition, :ensure_ordering

      def depth
        @depth ||= DepthCondition.new
      end

      def depth_present?
        @depth.present?
      end
    end
  end
end
