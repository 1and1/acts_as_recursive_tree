# frozen_string_literal: true

module ActsAsRecursiveTree
  module Builders
    extend ActiveSupport::Autoload

    autoload :Values
    autoload :DepthCondition
    autoload :QueryOptions
    autoload :Strategy
    autoload :RelationBuilder
    autoload :Descendants
    autoload :Ancestors
    autoload :Leaves
  end
end
