# frozen_string_literal: true

module ActsAsRecursiveTree
  class Railtie < Rails::Railtie
    initializer 'acts_as_recursive_tree.active_record_initializer' do
      ActiveRecord::Base.class_exec do
        extend ActsAsRecursiveTree::ActsMacro
      end
    end
  end
end
