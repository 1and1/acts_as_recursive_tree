module ActsAsRecursiveTree
  module Builders
    extend ActiveSupport::Autoload

    autoload :Values
    autoload :DepthCondition
    autoload :QueryOptions
    autoload :RelationBuilder
    autoload :Descendants
    autoload :Ancestors
    autoload :Leaves
  end
end
