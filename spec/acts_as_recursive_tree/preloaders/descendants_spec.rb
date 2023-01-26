# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActsAsRecursiveTree::Preloaders::Descendants do
  include TreeMethods

  let(:preloader) { described_class.new(root.reload, includes: included_associations) }
  let(:included_associations) { nil }
  let(:root) { create_tree(2, create_node_info: true) }
  let(:children) { root.children }

  describe '#preload! will set the associations target attribute' do
    before do
      preloader.preload!
    end

    it 'sets the children association' do
      children.each do |child|
        expect(child.association(:children).target).not_to be_nil
      end
    end

    it 'sets the parent association' do
      children.each do |child|
        expect(child.association(:parent).target).not_to be_nil
      end
    end
  end

  describe '#preload! will include associations' do
    let(:included_associations) { :node_info }

    before do
      preloader.preload!
    end

    it 'sets the children association' do
      children.each do |child|
        expect(child.association(included_associations).target).not_to be_nil
      end
    end
  end
end
