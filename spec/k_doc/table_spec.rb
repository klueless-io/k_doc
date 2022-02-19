# frozen_string_literal: true

require 'spec_helper'

class TableParent
  attr_reader :some_attribute
end

RSpec.describe KDoc::Table do
  let(:parent) { TableParent.new }
  let(:data) { {} }
  let(:instance) { described_class.new(parent, data) }

  describe '.key' do
    subject { instance.key }

    context 'when no key' do
      it { expect(subject).to eq('table') }
    end

    context 'when key supplied' do
      let(:instance) { described_class.new(parent, data, 'my-key') }

      it { expect(subject).to eq('my-key') }
    end
  end

  describe '.parent' do
    subject { instance.parent }

    it { is_expected.not_to be_nil }
  end

  context 'table grouping keys' do
    subject { data }

    context 'when key is nil' do
      before { described_class.new(parent, data) }

      it { is_expected.to eq({ 'table' => { 'fields' => [], 'rows' => [] } }) }
    end

    context 'when key is :key_values' do
      before { described_class.new(parent, data, :key_values) }

      it { is_expected.to eq({ 'key_values' => { 'fields' => [], 'rows' => [] } }) }
    end

    context 'and key is "key_values"' do
      before { described_class.new(parent, data, 'key_values') }

      it { is_expected.to eq({ 'key_values' => { 'fields' => [], 'rows' => [] } }) }
    end

    context 'tables for people, places and tables (default)' do
      before do
        described_class.new(parent, data, :people)
        described_class.new(parent, data)
        described_class.new(parent, data, :places)
      end

      it do
        is_expected.to eq(
          'people' => { 'fields' => [], 'rows' => [] },
          'table' => { 'fields' => [], 'rows' => [] },
          'places' => { 'fields' => [], 'rows' => [] }
        )
      end
    end
  end

  describe '#field' do
    context '@name of field' do
      context 'when name is string' do
        subject { instance.field('xmen') }

        it { is_expected.to include('name' => 'xmen') }
      end

      context 'when name is symbol' do
        subject { instance.field(:xmen) }

        it { is_expected.to include('name' => 'xmen') }
      end
    end

    context '@default value for field' do
      context 'when default not supplied' do
        subject { instance.field('xmen') }

        it { is_expected.to include('default' => nil) }
      end

      context 'when default value parsed in as positional argument' do
        subject { instance.field('xmen', 'are great') }

        it { is_expected.to include('default' => 'are great') }
      end

      context 'when default value parsed in named argument' do
        subject { instance.field('xmen', default: 'are excellent') }

        it { is_expected.to include('default' => 'are excellent') }
      end
    end

    context '@type of field' do
      context 'when type not supplied' do
        subject { instance.field('xmen') }

        it { is_expected.to include('type' => 'string') }
      end

      context 'when type parsed in as positional argument' do
        subject { instance.field('xmen', nil, :boolean) }

        it { is_expected.to include('type' => 'boolean') }
      end

      context 'when type parsed in named argument' do
        subject { instance.field('xmen', type: 'boolean') }

        it { is_expected.to include('type' => 'boolean') }
      end
    end

    context '@name, @default_value, @type combinations' do
      context '2 x positional parameters' do
        subject { instance.field('xmen', 'are excellent', 'decimal') }

        it { is_expected.to include('name' => 'xmen', 'default' => 'are excellent', 'type' => 'decimal') }
      end

      context '2 x named parameters' do
        subject { instance.field('xmen', type: 'text', default: 'are awesome') }

        it { is_expected.to include('name' => 'xmen', 'default' => 'are awesome', 'type' => 'text') }
      end

      # Often fields are defined using positional args
      # But a named default value may be introduced for override/specificity reasons
      context 'edge cases when using 3 positional parameters + :default' do
        subject { instance.field('xmen', nil, type, default: default) }

        let(:type) { 'string' }
        let(:default) { 'some string' }

        context 'when default is string' do
          it { is_expected.to include('name' => 'xmen', 'type' => 'string', 'default' => 'some string') }
        end

        context 'when type is boolean' do
          let(:type) { 'boolean' }
          let(:default) { true }

          context 'with true value' do
            it { is_expected.to include('name' => 'xmen', 'type' => 'boolean', 'default' => true) }
          end

          context 'with false value' do
            let(:default) { false }
            it { is_expected.to include('name' => 'xmen', 'type' => 'boolean', 'default' => false) }
          end
        end
      end
    end
  end

  context 'before block_eval' do
    before do
      described_class.new(parent, data) do
        fields :name, :type

        rows :xmen, :mutants
        rows :superman, :superhero
        rows :wolverine, :mutant
      end
    end

    describe '.data' do
      subject { data }

      it do
        is_expected.to eq(
          KDoc.opinion.default_table_key.to_s => {
            'fields' => [],
            'rows' => []
          }
        )
      end
    end
  end

  context 'after block_eval' do
    before { instance.fire_eval }

    describe '#get_fields' do
      subject { instance.get_fields }

      context 'when basic field definitions' do
        let(:instance) do
          described_class.new(parent, data) do
            fields :name, :type
          end
        end

        it do
          is_expected.to eq(
            [
              { 'name' => 'name', 'type' => 'string', 'default' => nil },
              { 'name' => 'type', 'type' => 'string', 'default' => nil }
            ]
          )
        end
      end

      context 'when field definition has default value' do
        let(:instance) do
          described_class.new(parent, data) do
            fields :column1, field(:column2, 'CUSTOM DEFAULT')
          end
        end

        it do
          is_expected.to eq(
            [
              { 'name' => 'column1', 'type' => 'string', 'default' => nil },
              { 'name' => 'column2', 'type' => 'string', 'default' => 'CUSTOM DEFAULT' }
            ]
          )
        end
      end

      context 'when field definition has default boolean FALSE' do
        let(:instance) do
          described_class.new(parent, data) do
            fields field(:column1, false), field(:column2, default: false)
          end
        end

        it do
          is_expected.to eq(
            [
              { 'name' => 'column1', 'type' => 'string', 'default' => false },
              { 'name' => 'column2', 'type' => 'string', 'default' => false }
            ]
          )
        end
      end

      context 'when field definition has default boolean TRUE' do
        let(:instance) do
          described_class.new(parent, data) do
            fields field(:column1, true), field(:column2, default: true)
          end
        end

        it do
          is_expected.to eq(
            [
              { 'name' => 'column1', 'type' => 'string', 'default' => true },
              { 'name' => 'column2', 'type' => 'string', 'default' => true }
            ]
          )
        end
      end

      context 'when field has custom :integer type and default value' do
        let(:instance) do
          described_class.new(parent, data) do
            fields :column1, field(:column2, 333, :integer)
          end
        end

        it do
          is_expected.to eq(
            [
              { 'name' => 'column1', 'type' => 'string', 'default' => nil },
              { 'name' => 'column2', 'type' => 'integer', 'default' => 333 }
            ]
          )
        end
      end

      context 'when field has custom :float type and default value' do
        let(:instance) do
          described_class.new(parent, data) do
            fields :column1, f(:column2, 3.33, type: :float)
          end
        end

        it do
          is_expected.to eq(
            [
              { 'name' => 'column1', 'type' => 'string', 'default' => nil },
              { 'name' => 'column2', 'type' => 'float', 'default' => 3.33 }
            ]
          )
        end
      end

      context 'when fields have custom type & default value using named parameters' do
        let(:instance) do
          described_class.new(parent, data) do
            fields :column1, f(:column2, default: 'CUSTOM VALUE', type: 'customtype')
          end
        end

        it do
          is_expected.to eq(
            [
              { 'name' => 'column1', 'type' => 'string', 'default' => nil },
              { 'name' => 'column2', 'type' => 'customtype', 'default' => 'CUSTOM VALUE' }
            ]
          )
        end
      end

      context 'when mixed set of examples' do
        let(:instance) do
          described_class.new(parent, data) do
            fields :name, f(:type, 'String'), f(:title, ''), f(:default, nil), f(:required, true, :bool), :reference_type, :db_type, :format_type, :description
          end
        end

        it do
          is_expected.to eq(
            [
              { 'name' => 'name', 'type' => 'string', 'default' => nil },
              { 'name' => 'type', 'type' => 'string', 'default' => 'String' },
              { 'name' => 'title', 'type' => 'string', 'default' => '' },
              { 'name' => 'default', 'type' => 'string', 'default' => nil },
              { 'name' => 'required', 'type' => 'bool', 'default' => true },
              { 'name' => 'reference_type', 'type' => 'string', 'default' => nil },
              { 'name' => 'db_type', 'type' => 'string', 'default' => nil },
              { 'name' => 'format_type', 'type' => 'string', 'default' => nil },
              { 'name' => 'description', 'type' => 'string', 'default' => nil }
            ]
          )
        end
      end
    end

    describe '#get_rows' do
      subject { instance.get_rows }

      context 'using positional arguments' do
        context 'with 2 rows, 2 columns and nil data' do
          let(:instance) do
            described_class.new(parent, data) do
              fields :column1, :column2

              row
              row
            end
          end

          it do
            is_expected.to eq(
              [
                { 'column1' => nil, 'column2' => nil },
                { 'column1' => nil, 'column2' => nil }
              ]
            )
          end
        end

        context 'with 2 rows, 2 columns and data' do
          let(:instance) do
            described_class.new(parent, data) do
              fields :column1, :column2

              row   'row1-c1', 'row1-c2'
              row   'row2-c1', 'row2-c2'
            end
          end

          it do
            is_expected.to eq(
              [
                { 'column1' => 'row1-c1', 'column2' => 'row1-c2' },
                { 'column1' => 'row2-c1', 'column2' => 'row2-c2' }
              ]
            )
          end
        end

        context 'with 2 rows, 2 columns using mixed nil mixed data' do
          let(:instance) do
            described_class.new(parent, data) do
              fields :column1, :column2

              row   nil, 'row1-c2'
              row   'row2-c1'
            end
          end

          it do
            is_expected.to eq(
              [
                { 'column1' => nil, 'column2' => 'row1-c2' },
                { 'column1' => 'row2-c1', 'column2' => nil }
              ]
            )
          end
        end

        context 'with 2 rows, 3 columns using mixed default types' do
          let(:instance) do
            described_class.new(parent, data) do
              fields :column1, :column2, f(:column3, false)

              row   nil, 'row1-c2', true
              row   'row2-c1'
            end
          end

          it do
            is_expected.to eq(
              [
                { 'column1' => nil, 'column2' => 'row1-c2', 'column3' => true },
                { 'column1' => 'row2-c1', 'column2' => nil, 'column3' => false }
              ]
            )
          end
        end
      end

      context 'using named arguments' do
        context 'with 2 rows, 2 columns using named values' do
          let(:instance) do
            described_class.new(parent, data) do
              fields :column1, :column2

              row column1: 'david'
              row column2: 'cruwys'
            end
          end

          it do
            is_expected.to eq(
              [
                { 'column1' => 'david', 'column2' => nil },
                { 'column1' => nil, 'column2' => 'cruwys' }
              ]
            )
          end
        end
      end

      context 'using positional and named arguments' do
        context 'add 2 rows, 2 columns with named values' do
          let(:instance) do
            described_class.new(parent, data) do
              fields :column1, :column2

              row 'david'
              row column2: 'cruwys'
            end
          end

          it do
            is_expected.to eq(
              [
                { 'column1' => 'david', 'column2' => nil },
                { 'column1' => nil, 'column2' => 'cruwys' }
              ]
            )
          end
        end
      end
    end
  end

  context 'error handling' do
    context 'when row.columns > fields.columns' do
      let(:instance) do
        described_class.new(parent, data) do
          fields :column1
          row 'row1-c1', 'row1-c2'
        end
      end

      it { expect { instance.fire_eval }.to raise_error(KType::Error, 'To many values for row, argument 2') }
    end
  end

  describe '#find_row' do
    before { instance.fire_eval }

    let(:instance) do
      described_class.new(parent, data) do
        fields :column1, :column2

        row 1
        row 2, :a
        row 3, :b
      end
    end

    context 'when row is found - example 1' do
      subject { instance.find_row('column1', 2) }

      it { is_expected.to eq({ 'column1' => 2, 'column2' => :a }) }
    end

    context 'when row is found - example 2' do
      subject { instance.find_row('column2', :b) }

      it { is_expected.to eq({ 'column1' => 3, 'column2' => :b }) }
    end
  end
end
