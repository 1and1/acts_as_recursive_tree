require 'active_support'


module ActsAsRecursiveTree
  extend ActiveSupport::Autoload

  autoload :ActsMacro
  autoload :Model
  autoload :Relation
  autoload :Scope
  autoload :Version
  autoload :QueryBuilder

  ActiveSupport.on_load :active_record do
    ActiveRecord::Base.send :extend, ActsAsRecursiveTree::ActsMacro
  end
end
