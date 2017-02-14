module ActsAsRecursiveTree
  module Builder
    extend ActiveSupport::Autoload

    autoload :Ids
    autoload :Base
    autoload :Descendants
    autoload :Ancestors
    autoload :Leaves
  end
end
