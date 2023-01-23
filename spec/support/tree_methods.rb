# frozen_string_literal: true

# Helper methods for simple tree creation
module TreeMethods
  def create_tree(max_level, current_level = 0, node = nil)
    node = Node.create!(name: 'root') if node.nil?

    1.upto(max_level - current_level) do |index|
      child = node.children.create!(name: "child #{index} - level #{current_level}")
      create_tree(max_level, current_level + 1, child)
    end

    node
  end
end
