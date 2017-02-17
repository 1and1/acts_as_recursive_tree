require 'spec_helper'

shared_examples 'single values' do
  subject(:value) { described_class.create(single_value) }

  it { is_expected.to be_a ActsAsRecursiveTree::Builder::Values::SingleValue }

  it 'should apply_to' do
    expect(value.apply_to(attribute).to_sql).to end_with " = #{single_value}"
  end

  it 'should apply_negated_to' do
    expect(value.apply_negated_to(attribute).to_sql).to end_with " != #{single_value}"
  end
end

describe ActsAsRecursiveTree::Builder::Values do
  let(:table) { Arel::Table.new('test_table') }
  let(:attribute) { table['test_attr'] }

  context 'single value' do
    let(:single_value) { 3 }

    it_behaves_like 'single values' do
      let(:value_obj) { single_value }
    end

    it_behaves_like 'single values' do
      let(:value_obj) { Node.new(id: single_value) }
    end

  end

  context 'multi value' do
    context 'Array' do
      let(:array) { [1, 2, 3] }
      subject(:value) { described_class.create(array) }

      it { is_expected.to be_a ActsAsRecursiveTree::Builder::Values::MultiValue }

      it 'should apply_to' do
        expect(value.apply_to(attribute).to_sql).to end_with " IN (#{array.join(', ')})"
      end

      it 'should apply_negated_to' do
        expect(value.apply_negated_to(attribute).to_sql).to end_with " NOT IN (#{array.join(', ')})"
      end
    end

    context 'Range' do
      let(:range) { 1..3 }
      subject(:value) { described_class.create(range) }

      it { is_expected.to be_a ActsAsRecursiveTree::Builder::Values::MultiValue }

      it 'should apply_to' do
        expect(value.apply_to(attribute).to_sql).to end_with "BETWEEN #{range.begin} AND #{range.end}"
      end

      it 'should apply_negated_to' do
        expect(value.apply_negated_to(attribute).to_sql).to match /< #{range.begin} OR.* > #{range.end}/
      end
    end

    context 'Relation' do
      let(:relation) { Node.where(name: 'test') }
      subject(:value) { described_class.create(relation, OpenStruct.new(primary_key: :id)) }

      it { is_expected.to be_a ActsAsRecursiveTree::Builder::Values::Relation }

      it 'should apply_to' do
        expect(value.apply_to(attribute).to_sql).to match /IN \(SELECT.*\)/
      end

      it 'should apply_negated_to' do
        expect(value.apply_negated_to(attribute).to_sql).to match /NOT IN \(SELECT.*\)/
      end
    end
  end
end