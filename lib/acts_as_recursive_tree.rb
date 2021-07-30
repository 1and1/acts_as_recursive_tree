# frozen_string_literal: true

require 'active_support/all'
require_relative 'acts_as_recursive_tree/railtie' if defined?(Rails)

module ActsAsRecursiveTree
  extend ActiveSupport::Autoload

  autoload :Config
  autoload :ActsMacro
  autoload :Model
  autoload :Associations
  autoload :Scopes
  autoload :Version
  autoload :Options
  autoload :Builders
end
