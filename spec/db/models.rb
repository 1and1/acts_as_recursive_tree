class Node < ActiveRecord::Base
  acts_as_tree
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