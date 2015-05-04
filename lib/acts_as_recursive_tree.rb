require 'active_support'


module ActsAsRecursiveTree
  extend ActiveSupport::Autoload

  autoload :ActsMacro
  autoload :Query
  autoload :Model
  autoload :Version

  ActiveSupport.on_load :active_record do
    ActiveRecord::Base.send :extend, ActsAsRecursiveTree::ActsMacro
  end
end
