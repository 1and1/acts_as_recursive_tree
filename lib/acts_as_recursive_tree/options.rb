# frozen_string_literal: true

module ActsAsRecursiveTree
  module Options
    extend ActiveSupport::Autoload

    autoload :Values
    autoload :DepthCondition
    autoload :QueryOptions
  end
end
