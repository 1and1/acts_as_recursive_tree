require 'spec_helper'


shared_examples 'basic recursive examples' do
  let(:builder) { described_class.new(model_class, model_id) }
  subject(:query) { builder.build.to_sql }

  it { is_expected.to start_with "SELECT \"#{model_class.table_name}\".* FROM \"#{model_class.table_name}\""}
  it { is_expected.to match /WITH RECURSIVE "#{builder.travers_loc_table.name}" AS/ }
  it { is_expected.to match /SELECT "#{model_class.table_name}"."#{model_class.primary_key}", "#{model_class.table_name}"."#{model_class._recursive_tree_config.parent_key}", 0 AS recursive_depth FROM "#{model_class.table_name}"/ }
  it { is_expected.to match /SELECT "#{model_class.table_name}"."#{model_class.primary_key}", "#{model_class.table_name}"."#{model_class._recursive_tree_config.parent_key}", \("#{builder.travers_loc_table.name}"."recursive_depth" \+ 1\) AS recursive_depth FROM "#{model_class.table_name}"/ }
  it { is_expected.to match /#{Regexp.escape(builder.travers_loc_table.project(Arel.star).to_sql)}/ }
  it { is_expected.to match /"#{model_class.table_name}"."#{model_class.primary_key}" = "#{builder.recursive_temp_table.name}"."#{model_class.primary_key}"/ }
end

shared_examples 'build recursive query' do
  context 'simple id' do
    let(:model_id) { 1 }
    it_behaves_like 'basic recursive examples' do
      let(:model_class) { Node }
    end

    it_behaves_like 'basic recursive examples' do
      let(:model_class) { NodeWithOtherParentKey }
    end

    it_behaves_like 'basic recursive examples' do
      let(:model_class) { Floor }
    end
  end


  context 'other' do


    let(:model_class) { Node }
    let(:model_id) { 1 }
    let(:builder) { described_class.new(model_class, model_id) }
    subject(:query) { builder.build.to_sql }

    it 'should work' do
      puts query
    end


    it { is_expected.to match /WHERE "#{model_class.table_name}"."#{model_class.primary_key}" = #{model_id}/ }
  end

end

describe ActsAsRecursiveTree::Builder::Descendants do
  it_behaves_like 'build recursive query'
end

describe ActsAsRecursiveTree::Builder::Ancestors do
  it_behaves_like 'build recursive query'
end

describe ActsAsRecursiveTree::Builder::Leaves do
  it_behaves_like 'build recursive query'
end
