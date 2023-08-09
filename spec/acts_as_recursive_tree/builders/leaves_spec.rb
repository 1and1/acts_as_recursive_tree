# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActsAsRecursiveTree::Builders::Leaves do
  context 'without additional setup' do
    it_behaves_like 'build recursive query'
    it_behaves_like 'descendant query'
    include_context 'without ordering'
  end

  context 'with options' do
    include_context 'with enforced ordering setup' do
      let(:ordering) { true }
      it_behaves_like 'not adding ordering'
    end
  end
end
