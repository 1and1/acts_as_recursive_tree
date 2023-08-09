# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActsAsRecursiveTree::Options::Values do
  shared_examples 'single values' do
    subject(:value) { described_class.create(single_value) }

    it { is_expected.to be_a described_class::SingleValue }

    it 'apply_toes' do
      expect(value.apply_to(attribute).to_sql).to end_with " = #{single_value}"
    end

    it 'apply_negated_toes' do
      expect(value.apply_negated_to(attribute).to_sql).to end_with " != #{single_value}"
    end
  end

  let(:table) { Arel::Table.new('test_table') }
  let(:attribute) { table['test_attr'] }

  context 'with invalid agurment' do
    it 'raises exception' do
      expect { described_class.create(nil) }.to raise_exception(/is not supported/)
    end
  end

  context 'with single value' do
    let(:single_value) { 3 }

    it_behaves_like 'single values' do
      let(:value_obj) { single_value }
    end

    it_behaves_like 'single values' do
      let(:value_obj) { Node.new(id: single_value) }
    end
  end

  context 'with multi value' do
    context 'with Array' do
      subject(:value) { described_class.create(array) }

      let(:array) { [1, 2, 3] }

      it { is_expected.to be_a described_class::MultiValue }

      it 'apply_toes' do
        expect(value.apply_to(attribute).to_sql).to end_with " IN (#{array.join(', ')})"
      end

      it 'apply_negated_toes' do
        expect(value.apply_negated_to(attribute).to_sql).to end_with " NOT IN (#{array.join(', ')})"
      end
    end

    context 'with Range' do
      subject(:value) { described_class.create(range) }

      let(:range) { 1..3 }

      it { is_expected.to be_a described_class::RangeValue }

      it 'apply_toes' do
        expect(value.apply_to(attribute).to_sql).to end_with "BETWEEN #{range.begin} AND #{range.end}"
      end

      it 'apply_negated_toes' do
        expect(value.apply_negated_to(attribute).to_sql).to match(/< #{range.begin} OR.* > #{range.end}/)
      end
    end

    context 'with Relation' do
      subject(:value) { described_class.create(relation, double) }

      let(:relation) { Node.where(name: 'test') }
      let(:double) do
        Class.new do
          def self.primary_key
            :id
          end
        end
      end

      it { is_expected.to be_a described_class::Relation }

      it 'apply_toes' do
        expect(value.apply_to(attribute).to_sql).to match(/IN \(SELECT.*\)/)
      end

      it 'apply_negated_toes' do
        expect(value.apply_negated_to(attribute).to_sql).to match(/NOT IN \(SELECT.*\)/)
      end
    end
  end
end
