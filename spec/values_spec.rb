# frozen_string_literal: true

require 'spec_helper'

shared_examples 'single values' do
  subject(:value) { described_class.create(single_value) }

  it { is_expected.to be_a ActsAsRecursiveTree::Options::Values::SingleValue }

  it 'apply_toes' do
    expect(value.apply_to(attribute).to_sql).to end_with " = #{single_value}"
  end

  it 'apply_negated_toes' do
    expect(value.apply_negated_to(attribute).to_sql).to end_with " != #{single_value}"
  end
end

describe ActsAsRecursiveTree::Options::Values do
  let(:table) { Arel::Table.new('test_table') }
  let(:attribute) { table['test_attr'] }

  context 'invalid agurment' do
    it 'raises exception' do
      expect { described_class.create(nil) }.to raise_exception(/is not supported/)
    end
  end

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
      subject(:value) { described_class.create(array) }

      let(:array) { [1, 2, 3] }

      it { is_expected.to be_a ActsAsRecursiveTree::Options::Values::MultiValue }

      it 'apply_toes' do
        expect(value.apply_to(attribute).to_sql).to end_with " IN (#{array.join(', ')})"
      end

      it 'apply_negated_toes' do
        expect(value.apply_negated_to(attribute).to_sql).to end_with " NOT IN (#{array.join(', ')})"
      end
    end

    context 'Range' do
      subject(:value) { described_class.create(range) }

      let(:range) { 1..3 }

      it { is_expected.to be_a ActsAsRecursiveTree::Options::Values::RangeValue }

      it 'apply_toes' do
        expect(value.apply_to(attribute).to_sql).to end_with "BETWEEN #{range.begin} AND #{range.end}"
      end

      it 'apply_negated_toes' do
        expect(value.apply_negated_to(attribute).to_sql).to match(/< #{range.begin} OR.* > #{range.end}/)
      end
    end

    context 'Relation' do
      subject(:value) { described_class.create(relation, OpenStruct.new(primary_key: :id)) }

      let(:relation) { Node.where(name: 'test') }

      it { is_expected.to be_a ActsAsRecursiveTree::Options::Values::Relation }

      it 'apply_toes' do
        expect(value.apply_to(attribute).to_sql).to match(/IN \(SELECT.*\)/)
      end

      it 'apply_negated_toes' do
        expect(value.apply_negated_to(attribute).to_sql).to match(/NOT IN \(SELECT.*\)/)
      end
    end
  end
end
