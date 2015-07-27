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

  describe 'root' do
    it 'should have 3 children' do
      expect(@root.children.count).to eql(3)
    end

    it 'should have 15 descendants' do

      expect(@root.descendants.count).to eql(3 + (3 * 2) + (3 * 2 * 1))
      expect(@root.descendants.all).to_not include(@root)
    end

    it 'should have 15 descendants and self' do
      expect(@root.self_and_descendants.count).to eql(@root.descendants.count + 1)
      expect(@root.self_and_descendants.all).to include(@root)
    end

    it '#root? should be true' do
      expect(@root.root?).to be true
    end

    it '#leaf? should be false' do
      expect(@root.leaf?).to be false
    end

    it 'should have 6 leaves' do
      expect(@root.leaves.count).to eql(6)
    end
  end

  describe 'child' do

    it 'should have root as parent' do
      expect(@child.parent).to eql(@root)
    end

    it 'should have 1 ancestor which is root' do
      expect(@child.ancestors.count).to eql(1)
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