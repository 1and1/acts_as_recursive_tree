# frozen_string_literal: true

# Base test class
class ApplicationRecord < ::ActiveRecord::Base
  self.abstract_class = true

  extend ActsAsRecursiveTree::ActsMacro
end

class Node < ApplicationRecord
  acts_as_tree
  has_one :node_info
end

class NodeInfo < ApplicationRecord
  belongs_to :node
end

class NodeWithPolymorphicParent < ApplicationRecord
  acts_as_tree parent_key: :other_id, parent_type_column: :other_type
end

class NodeWithOtherParentKey < ApplicationRecord
  acts_as_tree parent_key: :other_id
end

class Location < ApplicationRecord
  acts_as_tree
end

class Building < Location
end

class Floor < Location
end

class Room < Location
end
