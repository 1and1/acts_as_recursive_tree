# frozen_string_literal: true

module ActsAsRecursiveTree
  module Options
    class QueryOptions
      STRATEGIES = %i[subselect join].freeze

      def self.from
        options = new
        yield(options) if block_given?
        options
      end

      attr_accessor :condition
      attr_reader :ensure_ordering, :query_strategy

      def depth
        @depth ||= DepthCondition.new
      end

      def ensure_ordering!
        @ensure_ordering = true
      end

      def depth_present?
        @depth.present?
      end

      def query_strategy=(strategy)
        raise "invalid strategy #{strategy} - only #{STRATEGIES} are allowed" unless STRATEGIES.include?(strategy)

        @query_strategy = strategy
      end
    end
  end
end
