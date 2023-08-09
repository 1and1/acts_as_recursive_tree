# frozen_string_literal: true

RSpec.shared_context 'with enforced ordering setup' do
  let(:ordering) { false }
  include_context 'with base_setup' do
    let(:proc) { ->(config) { config.ensure_ordering! } }
  end
end

RSpec.shared_context 'with base_setup' do
  subject(:query) { builder.build.to_sql }

  let(:model_id) { 1 }
  let(:model_class) { Node }
  let(:exclude_ids) { false }
  let(:proc) { nil }
  let(:builder) do
    described_class.new(model_class, model_id, exclude_ids: exclude_ids, &proc)
  end
end

RSpec.shared_examples 'basic recursive examples' do
  it { is_expected.to start_with "SELECT \"#{model_class.table_name}\".* FROM \"#{model_class.table_name}\"" }

  it { is_expected.to match(/WHERE "#{model_class.table_name}"."#{model_class.primary_key}" = #{model_id}/) }

  it { is_expected.to match(/WITH RECURSIVE "#{builder.travers_loc_table.name}" AS/) }

  it { is_expected.to match(/SELECT "#{model_class.table_name}"."#{model_class.primary_key}", "#{model_class.table_name}"."#{model_class._recursive_tree_config.parent_key}", 0 AS recursive_depth FROM "#{model_class.table_name}"/) }

  it {
    expect(subject).to match(/SELECT "#{model_class.table_name}"."#{model_class.primary_key}", "#{model_class.table_name}"."#{model_class._recursive_tree_config.parent_key}", \("#{builder.travers_loc_table.name}"."recursive_depth" \+ 1\) AS recursive_depth FROM "#{model_class.table_name}"/)
  }
end

RSpec.shared_examples 'build recursive query' do
  context 'with simple id' do
    context 'with simple class' do
      include_context 'with base_setup' do
        let(:model_class) { Node }
        it_behaves_like 'basic recursive examples'
      end
    end

    context 'with class with different parent key' do
      include_context 'with base_setup' do
        let(:model_class) { NodeWithOtherParentKey }
        it_behaves_like 'basic recursive examples'
      end
    end

    context 'with Subclass' do
      include_context 'with base_setup' do
        let(:model_class) { Floor }
        it_behaves_like 'basic recursive examples'
      end
    end

    context 'with polymorphic parent relation' do
      include_context 'with base_setup' do
        let(:model_class) { NodeWithPolymorphicParent }
        it_behaves_like 'basic recursive examples'
      end
    end
  end
end

RSpec.shared_examples 'ancestor query' do
  include_context 'with base_setup'

  it { is_expected.to match(/"#{builder.travers_loc_table.name}"."#{model_class._recursive_tree_config.parent_key}" = "#{model_class.table_name}"."#{model_class.primary_key}"/) }
end

RSpec.shared_examples 'descendant query' do
  include_context 'with base_setup'

  it { is_expected.to match(/"#{model_class.table_name}"."#{model_class._recursive_tree_config.parent_key}" = "#{builder.travers_loc_table.name}"."#{model_class.primary_key}"/) }
  it { is_expected.to match(/#{Regexp.escape(builder.travers_loc_table.project(builder.travers_loc_table[model_class.primary_key]).to_sql)}/) }
end

RSpec.shared_context 'with ordering' do
  include_context 'with base_setup' do
    it_behaves_like 'is adding ordering'
  end
end

RSpec.shared_context 'without ordering' do
  include_context 'with base_setup' do
    it_behaves_like 'not adding ordering'
  end
end

RSpec.shared_examples 'is adding ordering' do
  it { is_expected.to match(/ORDER BY #{Regexp.escape(builder.recursive_temp_table[model_class._recursive_tree_config.depth_column].asc.to_sql)}/) }
end

RSpec.shared_examples 'not adding ordering' do
  it { is_expected.not_to match(/ORDER BY/) }
end
