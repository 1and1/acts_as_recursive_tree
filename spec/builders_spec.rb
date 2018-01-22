require 'spec_helper'

shared_context 'setup with enforced ordering' do
  let(:ordering) { false }
  include_context 'base_setup' do
    let(:proc) { -> (config) { config.ensure_ordering! } }
  end
end

shared_context 'base_setup' do
  let(:model_id) { 1 }
  let(:model_class) { Node }
  let(:exclude_ids) { false }
  let(:proc) { nil }
  let(:builder) do
    described_class.new(model_class, model_id, exclude_ids: exclude_ids, &proc)
  end
  subject(:query) { builder.build.to_sql }
end

shared_examples 'basic recursive examples' do
  it { is_expected.to start_with "SELECT \"#{model_class.table_name}\".* FROM \"#{model_class.table_name}\"" }
  it { is_expected.to match /WHERE "#{model_class.table_name}"."#{model_class.primary_key}" = #{model_id}/ }
  it { is_expected.to match /WITH RECURSIVE "#{builder.travers_loc_table.name}" AS/ }
  it { is_expected.to match /SELECT "#{model_class.table_name}"."#{model_class.primary_key}", "#{model_class.table_name}"."#{model_class._recursive_tree_config.parent_key}", 0 AS recursive_depth FROM "#{model_class.table_name}"/ }
  it { is_expected.to match /SELECT "#{model_class.table_name}"."#{model_class.primary_key}", "#{model_class.table_name}"."#{model_class._recursive_tree_config.parent_key}", \("#{builder.travers_loc_table.name}"."recursive_depth" \+ 1\) AS recursive_depth FROM "#{model_class.table_name}"/ }
  it { is_expected.to match /#{Regexp.escape(builder.travers_loc_table.project(Arel.star).to_sql)}/ }
  it { is_expected.to match /"#{model_class.table_name}"."#{model_class.primary_key}" = "#{builder.recursive_temp_table.name}"."#{model_class.primary_key}"/ }
end

shared_examples 'build recursive query' do
  context 'simple id' do
    context 'with simple class' do
      include_context 'base_setup' do
        let(:model_class) { Node }
        it_behaves_like 'basic recursive examples'
      end
    end

    context 'with class with different parent key' do
      include_context 'base_setup' do
        let(:model_class) { NodeWithOtherParentKey }
        it_behaves_like 'basic recursive examples'
      end
    end

    context 'with Subclass' do
      include_context 'base_setup' do
        let(:model_class) { Floor }
        it_behaves_like 'basic recursive examples'
      end
    end

    context 'with polymorphic parent relation' do
      include_context 'base_setup' do
        let(:model_class) { NodeWithPolymorphicParent }
        it_behaves_like 'basic recursive examples'
      end
    end
  end
end

shared_examples 'ancestor query' do
  include_context 'base_setup'

  it { is_expected.to match /"#{builder.travers_loc_table.name}"."#{model_class._recursive_tree_config.parent_key}" = "#{model_class.table_name}"."#{model_class.primary_key}"/ }
end

shared_examples 'descendant query' do
  include_context 'base_setup'

  it { is_expected.to match /"#{model_class.table_name}"."#{model_class._recursive_tree_config.parent_key}" = "#{builder.travers_loc_table.name}"."#{model_class.primary_key}"/ }
end

shared_context 'context with ordering' do
  include_context 'base_setup' do
    it_behaves_like 'with ordering'
  end
end

shared_context 'context without ordering' do
  include_context 'base_setup' do
    it_behaves_like 'without ordering'
  end
end

shared_examples 'with ordering' do
  it { is_expected.to match /ORDER BY #{Regexp.escape(builder.recursive_temp_table[model_class._recursive_tree_config.depth_column].asc.to_sql)}/ }
end

shared_examples 'without ordering' do
  it { is_expected.to_not match /ORDER BY/ }
end

describe ActsAsRecursiveTree::Builders::Descendants do
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

describe ActsAsRecursiveTree::Builders::Ancestors do
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

describe ActsAsRecursiveTree::Builders::Leaves do
  context 'basic' do
    it_behaves_like 'build recursive query'
    it_behaves_like 'descendant query'
    include_context 'context without ordering'
  end

  context 'with options' do
    include_context 'setup with enforced ordering' do
      let(:ordering) { true }
      it_behaves_like 'without ordering'
    end
  end
end
