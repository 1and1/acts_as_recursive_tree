module ActsAsRecursiveTree
  module Builder
    extend ActiveSupport::Autoload

    autoload :Values
    autoload :QueryOptions
    autoload :Base
    autoload :Descendants
    autoload :Ancestors
    autoload :Leaves
  end
end
