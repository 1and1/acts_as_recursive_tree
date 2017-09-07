ActiveRecord::Base.class_exec do
  extend ActsAsRecursiveTree::ActsMacro
end

class Node < ActiveRecord::Base
  acts_as_tree
  has_one :node_info
end

class NodeInfo < ActiveRecord::Base
  belongs_to :node
end

class NodeWithPolymorphicParent < ActiveRecord::Base
  acts_as_tree parent_key: :other_id, parent_type_column: :other_type
end


class NodeWithOtherParentKey < ActiveRecord::Base
  acts_as_tree parent_key: :other_id
end

class Location < ActiveRecord::Base
  acts_as_tree
end

class Building < Location

end

class Floor < Location

end

class Room < Location

end