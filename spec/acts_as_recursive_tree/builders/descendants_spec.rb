# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActsAsRecursiveTree::Builders::Descendants do
  context 'basic' do
    it_behaves_like 'build recursive query'
    it_behaves_like 'descendant query'
    include_context 'context without ordering'
  end

  context 'with options' do
    include_context 'setup with enforced ordering' do
      let(:ordering) { true }
      it_behaves_like 'with ordering'
    end
  end
end
