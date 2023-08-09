# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActsAsRecursiveTree::Builders::Ancestors do
  context 'without additional setup' do
    it_behaves_like 'build recursive query'
    it_behaves_like 'ancestor query'
    include_context 'with ordering'
  end

  context 'with options' do
    include_context 'with enforced ordering setup' do
      it_behaves_like 'is adding ordering'
    end
  end
end
