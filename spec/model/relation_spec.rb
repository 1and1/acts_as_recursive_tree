require 'spec_helper'

describe 'Relation' do

  def create_tree(max_level, current_level: 0, node: nil, stop_at: nil)

    if node.nil?
      node = Node.create!(name: 'root')
    end

    1.upto(max_level - current_level) do |index|
      child = node.children.create!(name: "child #{index} - level #{current_level}", active: stop_at > current_level)
      child.create_node_info(status: stop_at > current_level ? 'foo' : 'bar')
      create_tree(max_level, current_level: current_level + 1, node: child, stop_at: stop_at)
    end

    node
  end

  before do
    @root  = create_tree(4, stop_at: 2)
    @child = @root.children.first
  end

  context 'descendants' do

    it 'works with simple relation' do
      desc = @root.descendants(->(opts) { opts.condition = Node.where(active: true) })
      desc.all.each do |node|
        expect(node.active).to be_truthy
      end
    end

    it 'works with joins relation' do
      desc = @root.descendants(->(opts) { opts.condition = Node.joins(:node_info).where.not(node_infos: { status: 'bar' }) })
      desc.all.each do |node|
        expect(node.node_info.status).to eql('foo')
      end
    end
  end

  context 'ancestors' do

    it 'works with simple relation' do
      ancestors = @root.leaves.first.ancestors(
          lambda do |opts|
            opts.condition = Node.where(active: false)
          end
      ).all.to_a

      ancestors.each do |node|
        expect(node.active).to be_falsey
      end

      expect(ancestors).to_not include(@root)
    end

    it 'works with joins relation' do
      ancestors = @root.leaves.first.ancestors(->(opts) { opts.condition = Node.joins(:node_info).where.not(node_infos: { status: 'foo' }) })
      ancestors.all.each do |node|
        expect(node.node_info.status).to eql('bar')
      end
      expect(ancestors).to_not include(@root)
    end
  end

end