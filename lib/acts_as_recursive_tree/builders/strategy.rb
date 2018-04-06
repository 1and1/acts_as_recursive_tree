module ActsAsRecursiveTree
  module Builders
    #
    # Strategy module for different strategies of how to build the resulting query.
    #
    module Strategy
      extend ActiveSupport::Autoload

      autoload :Join
      autoload :Subselect

      #
      # Returns a Strategy appropriate for query_opts
      #
      # @param query_opts [ActsAsRecursiveTree::Options::QueryOptions]
      #
      # @return a strategy class best suited for the opts
      def self.for_query_options(query_opts)
        if query_opts.depth_present? || query_opts.ensure_ordering
          Join
        else
          Subselect
        end
      end
    end
  end
end
