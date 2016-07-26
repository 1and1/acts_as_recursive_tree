require 'spec_helper'

describe Node do

  def create_tree(max_level, current_level = 0, node = nil)

    if node.nil?
      node = Node.create!(name: 'root')
    end

    1.upto(max_level - current_level) do |index|
      child = node.children.create!(name: "child #{index} - level #{current_level}")
      create_tree(max_level, current_level + 1, child)
    end

    node
  end

  before do
    @root  = create_tree(3)
    @child = @root.children.first
  end

  context '#children' do
    it 'should have 3 children' do
      expect(@root.children.count).to eql(3)
    end

    it 'should not include root node ' do
      expect(@root.children).to_not include(@root)
    end

  end

  context '#descendants' do

    it 'should have 15 descendants' do
      expect(@root.descendants.count).to eql(3 + (3 * 2) + (3 * 2 * 1))
    end

    it 'should not include root' do
      expect(@root.descendants).to_not include(@root)
    end
  end
  context '#self_and_descendants' do

    it 'should have 15 descendants and self' do
      expect(@root.self_and_descendants.count).to eql(@root.descendants.count + 1)
    end

    it 'should include self' do
      expect(@root.self_and_descendants.all).to include(@root)
    end
  end

  context '#root?' do

    it 'should be true for root node' do
      expect(@root.root?).to be_truthy
    end

    it 'should be false for children' do
      expect(@child.root?).to be_falsey
    end

  end

  context '#leaf?' do

    it 'should be false for root node' do
      expect(@root.leaf?).to be_falsey
    end

    it 'should be true for children' do
      expect(@root.leaves.first.leaf?).to be_truthy
    end

  end

  context '#leaves' do
    it 'should have 6 leaves' do
      expect(@root.leaves.count).to eql(6)
    end
  end

  describe 'child' do

    it 'should have root as parent' do
      expect(@child.parent).to eql(@root)
    end

    it 'should have 1 ancestor' do
      expect(@child.ancestors.count).to eql(1)
    end

    it 'should have root as only ancestor' do
      expect(@child.ancestors.first).to eql(@root)
    end

    it '#root should return root' do
      expect(@child.root).to eql(@root)
    end

    it '#root? should be false' do
      expect(@child.root?).to be false
    end

    it '#leaf? should be false' do
      expect(@child.leaf?).to be false
    end
  end


  describe 'scopes' do

    context 'roots' do

      it 'has only one root node' do
        expect(Node.roots.count).to eql(1)
      end

      it 'is the @root node' do
        expect(Node.roots.first).to eql(@root)
      end
    end

  end
end