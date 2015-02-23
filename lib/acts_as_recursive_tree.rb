require 'active_support'


module ActsAsRecursiveTree
  extend ActiveSupport::Autoload

  autoload :ActsMacro
  autoload :ClassMethods
  autoload :InstanceMethods
  autoload :Version

  ActiveSupport.on_load :active_record do
    ActiveRecord::Base.send :extend, ClosureTree::HasClosureTree


  end
end
