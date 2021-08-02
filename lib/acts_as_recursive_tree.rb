# frozen_string_literal: true

require_relative 'acts_as_recursive_tree/railtie' if defined?(Rails)
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module ActsAsRecursiveTree
  # nothing special here
end
