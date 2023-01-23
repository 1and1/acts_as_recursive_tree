# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActsAsRecursiveTree::Preloaders::Descendants do
  include TreeMethods

  let(:preloader) { described_class.new(root.reload) }
  let(:root) { create_tree(2) }
  let(:children) { root.children }

  describe '#preload! will set the associations target attribute' do
    before do
      preloader.preload!
    end

    it 'sets the children assoction' do
      children.each do |child|
        expect(child.association(:children).target).not_to be_nil
      end
    end

    it 'sets the parent assoction' do
      children.each do |child|
        expect(child.association(:parent).target).not_to be_nil
      end
    end
  end
end
