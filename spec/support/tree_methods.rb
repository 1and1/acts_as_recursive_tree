# frozen_string_literal: true

# Helper methods for simple tree creation
module TreeMethods
  def create_tree(max_level, current_level: 0, node: nil, create_node_info: false, stop_at: -1)
    node = Node.create!(name: 'root') if node.nil?

    1.upto(max_level - current_level) do |index|
      child = node.children.create!(
        name: "child #{index} - level #{current_level}",
        active: stop_at > current_level
      )

      child.create_node_info(status: stop_at > current_level ? 'foo' : 'bar') if create_node_info

      create_tree(
        max_level,
        current_level: current_level + 1,
        node: child,
        create_node_info: create_node_info,
        stop_at: stop_at
      )
    end

    node
  end
end
