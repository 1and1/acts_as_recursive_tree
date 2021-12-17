# frozen_string_literal: true

require 'spec_helper'

describe Node do
  def create_tree(max_level, current_level = 0, node = nil)
    node = Node.create!(name: 'root') if node.nil?

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

  describe '#children' do
    it 'has 3 children' do
      expect(@root.children.count).to be(3)
    end

    it 'does not include root node' do
      expect(@root.children).not_to include(@root)
    end
  end

  describe '#descendants' do
    it 'has 15 descendants' do
      expect(@root.descendants.count).to eql(3 + (3 * 2) + (3 * 2 * 1))
    end

    it 'does not include root' do
      expect(@root.descendants).not_to include(@root)
    end
  end

  describe '#self_and_descendants' do
    it 'has 15 descendants and self' do
      expect(@root.self_and_descendants.count).to eql(@root.descendants.count + 1)
    end

    it 'includes self' do
      expect(@root.self_and_descendants.all).to include(@root)
    end
  end

  describe '#root?' do
    it 'is true for root node' do
      expect(@root).to be_root
    end

    it 'is false for children' do
      expect(@child).not_to be_root
    end
  end

  describe '#leaf?' do
    it 'is false for root node' do
      expect(@root).not_to be_leaf
    end

    it 'is true for children' do
      expect(@root.leaves.first).to be_leaf
    end
  end

  describe '#leaves' do
    it 'has 6 leaves' do
      expect(@root.leaves.count).to be(6)
    end
  end

  describe 'child' do
    it 'has root as parent' do
      expect(@child.parent).to eql(@root)
    end

    it 'has 1 ancestor' do
      expect(@child.ancestors.count).to be(1)
    end

    it 'has root as only ancestor' do
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
        expect(described_class.roots.count).to be(1)
      end

      it 'is the @root node' do
        expect(described_class.roots.first).to eql(@root)
      end
    end
  end
end
