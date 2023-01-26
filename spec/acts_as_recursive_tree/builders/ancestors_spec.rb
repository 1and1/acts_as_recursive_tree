# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActsAsRecursiveTree::Builders::Ancestors do
  context 'basic' do
    it_behaves_like 'build recursive query'
    it_behaves_like 'ancestor query'
    include_context 'context with ordering'
  end

  context 'with options' do
    include_context 'setup with enforced ordering' do
      it_behaves_like 'with ordering'
    end
  end
end
