# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Relation' do
  include TreeMethods

  let(:root) { create_tree(4, stop_at: 2) }

  describe '#descendants' do
    context 'with simple relation' do
      let(:descendants) { root.descendants { |opts| opts.condition = Node.where(active: true) }.to_a }

      it 'returns only active nodes' do
        descendants.each do |node|
          expect(node.active).to be_truthy
        end
      end
    end

    context 'with condition on joined association' do
      let(:descendants) do
        root.descendants do |opts|
          opts.condition = Node.joins(:node_info).where.not(node_infos: { status: 'bar' })
        end
      end

      it 'returns only node with condition fulfilled' do
        descendants.each do |node|
          expect(node.node_info.status).to eql('foo')
        end
      end
    end
  end

  describe '#ancestors' do
    context 'with simple_relation' do
      let(:ancestors) { root.leaves.first.ancestors { |opts| opts.condition = Node.where(active: false) }.to_a }

      it 'return only active nodes' do
        ancestors.each do |node|
          expect(node.active).to be_falsey
        end
      end

      it 'does not return the root node' do
        expect(ancestors).not_to include(root)
      end
    end

    context 'with condition on joined association' do
      let(:ancestors) do
        root.leaves.first.ancestors do |opts|
          opts.condition = Node.joins(:node_info).where.not(node_infos: { status: 'foo' })
        end
      end

      it 'return only nodes for the matching condition' do
        ancestors.each do |node|
          expect(node.node_info.status).to eql('bar')
        end
      end

      it 'does not return the root node' do
        expect(ancestors).not_to include(root)
      end
    end
  end
end
