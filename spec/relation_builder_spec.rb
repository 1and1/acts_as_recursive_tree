require_relative 'spec_helper'

describe ActsAsRecursiveTree::RelationBuilder do

  let (:builder) { described_class.new(Node, 1, only_leaves: true) }

  it 'works' do
    #puts builder.build.to_sql
  end


end