# frozen_string_literal: true

module ActsAsRecursiveTree
  module Builders
    #
    # Strategy module for different strategies of how to build the resulting query.
    #
    module Strategies
      #
      # Returns a Strategy appropriate for query_opts
      #
      # @param query_opts [ActsAsRecursiveTree::Options::QueryOptions]
      #
      # @return a strategy class best suited for the opts
      def self.for_query_options(query_opts)
        if query_opts.ensure_ordering || query_opts.query_strategy == :join
          Join
        else
          Subselect
        end
      end
    end
  end
end
