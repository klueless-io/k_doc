# frozen_string_literal: true

require 'spec_helper'

# class Pluralizer
#   def update(data)
#     return unless data.key?('model') && (!data.key?('model_plural') || data['model_plural'].nil?)

#     data['model_plural'] = "#{data['model']}s"
#   end
# end

# class AlterKeyValues
#   def update(data)
#     data.update(data) do |key, value|
#       if key.to_s == 'first_name'
#         value.gsub('David', 'Davo')
#       elsif key.to_s == 'last_name'
#         value.gsub('Cruwys', 'The Great')
#       else
#         value
#       end
#     end
#     data['full_name'] = "#{data['first_name']} #{data['last_name']}"
#   end
# end

# class AlterStructure
#   def update(data)
#     return unless data.key?('full_name')

#     data['funny_name'] = data['full_name'].downcase
#     data.delete('full_name')
#   end
# end

RSpec.describe KDoc::Document do
  subject { instance }

  let(:instance) { described_class.new(key, &block) }

  let(:key) { 'some_name' }
  let(:type) { :controller }
  let(:namespace) { :spaceman }
  let(:block) { nil }

  describe '#constructor' do
    context 'with no key' do
      let(:instance) { described_class.new }

      it {
        is_expected.to have_attributes(
          key: match(/^[A-Za-z0-9]{8}$/),
          type: KDoc.opinion.default_document_type,
          namespace: '',
          options: {},
          data: {}
        )
      }
    end

    context 'with key only' do
      let(:instance) { described_class.new(key) }

      it { expect(subject.key).to eq(key) }

      context 'with key and type' do
        let(:instance) { described_class.new(key, type: type) }

        it 'type is set' do
          expect(subject.type).to eq(type)
        end

        context 'when type is' do
          subject { instance.type }

          context 'nil' do
            let(:type) { nil }

            it { is_expected.to eq(KDoc.opinion.default_document_type) }
          end

          context ':some_data_type' do
            let(:type) { :some_data_type }

            it { is_expected.to eq(:some_data_type) }
          end
        end

        context 'with key, type and namespace' do
          let(:instance) { described_class.new(key, type: type, namespace: namespace) }

          it 'namespace is set' do
            expect(subject.namespace).to eq(:spaceman)
          end
          it 'options have namespace' do
            expect(subject.options).not_to include(namespace: :spaceman)
          end
          it 'options have type' do
            expect(subject.options).not_to include(type: :controller)
          end
        end

        context 'with key, type and other options' do
          subject { instance.options }

          let(:instance) { described_class.new(key, type: type, **options) }

          let(:options) { {} }

          it { is_expected.to eq({}) }

          context 'when custom options are provided' do
            let(:options) { { a: 1, b: '2' } }

            it { is_expected.to eq(a: 1, b: '2') }
          end

          context 'when default_data option is provided' do
            let(:options) { { default_data: { a: 1, b: '2' } } }

            it { is_expected.to eq({}) }

            it 'alters the default starting data to {:a=>1, :b=>"2"}' do
              expect(instance.data).to eq(a: 1, b: '2')
            end
          end
        end
      end
    end

    context 'with &block' do
      subject { described_class.new key, **options, &block }

      let(:options) { {} }
      let(:block) do
        lambda do |_|
          @data = { thunder_birds: :are_go }
        end
      end

      context 'when given a block' do
        it { expect(subject.data).to eq({}) }

        context 'after execute_block' do
          before { subject.execute_block }

          it { expect(subject.data).to eq(thunder_birds: :are_go) }
        end
      end
    end
  end

  describe '.unique_key' do
    context 'with key' do
      subject { described_class.new(key).unique_key }

      it { expect(subject).to eq("some_name_#{KDoc.opinion.default_document_type}") }
    end

    context 'with key and type' do
      subject { described_class.new(key, type: type).unique_key }

      it { expect(subject).to eq('some_name_controller') }
    end

    context 'with key, type and namespace' do
      subject { described_class.new(key, type: type, namespace: namespace).unique_key }

      it { expect(subject).to eq('spaceman_some_name_controller') }
    end
  end

  describe '#get_node_type' do
    # subject { instance.data}

    before { instance.execute_block }

    let(:block) do
      lambda do |_|
        settings do
          # Some settings with the key: :settings
        end

        settings :key_values do
          # Some settings with the key: :key_values
        end

        table do
          # A table under with the name: :table
        end

        table :custom do
          # A table under with the name: :custom
        end
      end
    end

    it { expect { subject.get_node_type(:xmen) }.to raise_error(KDoc::Error) }
    it { expect(subject.get_node_type(:settings)).to eq(:settings) }
    it { expect(subject.get_node_type('settings')).to eq(:settings) }
    it { expect(subject.get_node_type('key_values')).to eq(:settings) }
    it { expect(subject.get_node_type('table')).to eq(:table) }
    it { expect(subject.get_node_type('custom')).to eq(:table) }
  end

  describe '.raw_data' do
    subject { instance.raw_data }

    before { instance.execute_block }

    let(:block) do
      lambda do |_|
        settings do
          # Some settings under :settings
        end

        settings :key_values do
          # Some settings under :key_values
        end

        table do
          # A table under :table
        end

        table :custom do
          # A table under :custom
        end
      end
    end

    # Data: Includes Meta, eg. fields
    # {"settings"=>{}, "key_values"=>{}, "table"=>{"fields"=>[], "rows"=>[]}, "custom"=>{"fields"=>[], "rows"=>[]}}

    # RawData: Excludes Meta
    # {"settings"=>{}, "key_values"=>{}, "table"=>{"rows"=>[]}, "custom"=>{"rows"=>[]}}
    it { is_expected.to eq({ 'settings' => {}, 'key_values' => {}, 'table' => [], 'custom' => [] }) }
  end

  describe 'configure settings' do
    context 'default DI/IOC class' do
      subject { instance.settings }

      it { expect(subject).to be_a(KDoc::Settings) }
    end

    context '.data' do
      subject { instance.data }

      before { instance.execute_block }

      context 'setting groups' do
        context 'with default name' do
          let(:block) do
            lambda do |_|
              settings do
                # Some settings with the key: :settings
              end
            end
          end

          it { is_expected.to eq('settings' => {}) }
        end

        context 'with custom name' do
          let(:block) do
            lambda do |_|
              settings :key_values do
                # Some settings with the key: :key_values
              end
            end
          end

          it { is_expected.to eq('key_values' => {}) }
        end

        context 'with multiple groups' do
          let(:block) do
            lambda do |_|
              settings do
                # Some settings with the key: :key_values
              end
              settings :key_values do
                # Some settings with the key: :key_values
              end
              settings :name_values do
                # Some settings with the key: :name_values
              end
            end
          end

          it { is_expected.to eq('settings' => {}, 'key_values' => {}, 'name_values' => {}) }
        end
      end

      context 'setting key/values' do
        let(:block) do
          lambda do |_|
            settings do
              model             'user'
              rails_port        3000
              active            true
            end
          end
        end

        it do
          is_expected.to eq('settings' =>
            {
              'model' => 'user',
              'rails_port' => 3000,
              'active' => true
            })
        end

        # context 'with decorators - sample 1' do
        #   let(:block) do
        #     lambda do |_|
        #       settings decorators: [Pluralizer, :uppercase] do
        #         model             'user'
        #         rails_port        3000
        #         active            true
        #       end
        #     end
        #   end

        #   it do
        #     is_expected.to eq('settings' =>
        #       {
        #         'model' => 'USER',
        #         'model_plural' => 'USERS',
        #         'rails_port' => 3000,
        #         'active' => true
        #       })
        #   end
        # end

        # context 'with decorators - sample 2' do
        #   let(:block) do
        #     lambda do |_|
        #       settings decorators: [AlterKeyValues, AlterStructure] do
        #         first_name 'David'
        #         last_name 'Cruwys'
        #         age 40
        #       end
        #     end
        #   end

        #   it do
        #     is_expected.to eq('settings' =>
        #       {
        #         'first_name' => 'Davo',
        #         'last_name' => 'The Great',
        #         'funny_name' => 'davo the great',
        #         'age' => 40
        #       })
        #   end
        # end
      end
    end
  end

  describe 'configure table' do
    before { instance.execute_block }

    context 'default DI/IOC class' do
      subject { instance.table }

      it { expect(subject).to be_a(KDoc::Table) }
    end

    context '.data' do
      subject { instance.data }

      context 'table groups' do
        context 'with default key' do
          let(:block) do
            lambda do |_|
              table do
                # A table under the name: :table
              end
            end
          end

          it { is_expected.to eq('table' => { 'fields' => [], 'rows' => [] }) }
        end

        context 'with custom key' do
          let(:block) do
            lambda do |_|
              table :custom do
                # A table under the name: :custom
              end
            end
          end

          it { is_expected.to eq('custom' => { 'fields' => [], 'rows' => [] }) }
        end

        context 'with multiple tables' do
          let(:block) do
            lambda do |_|
              table do
                # A table under the name: :table
              end

              table :table2 do
                # A table under the name: :table2
              end

              table :table3 do
                # A table under the name: :table3
              end
            end
          end

          it do
            is_expected.to eq({
                                'table' => { 'fields' => [], 'rows' => [] },
                                'table2' => { 'fields' => [], 'rows' => [] },
                                'table3' => { 'fields' => [], 'rows' => [] }
                              })
          end
        end
      end

      context 'table rows' do
        let(:block) do
          lambda do |_|
            table do
              fields [:column1, :column2, f(:column3, false), f(:column4, default: 'CUSTOM VALUE')]

              row 'row1-c1', 'row1-c2', true, 'row1-c4'
              row
            end

            table :another_table do
              fields %w[column1 column2]

              row column1: 'david'
              row column2: 'cruwys'
            end
          end
        end

        it 'multiple row groups, multiple rows and positional and key/valued data' do
          is_expected.to eq({
                              'table' => {
                                'fields' => [
                                  { 'name' => 'column1', 'type' => 'string', 'default' => nil },
                                  { 'name' => 'column2', 'type' => 'string', 'default' => nil },
                                  { 'name' => 'column3', 'type' => 'string', 'default' => false },
                                  { 'name' => 'column4', 'type' => 'string', 'default' => 'CUSTOM VALUE' }
                                ],
                                'rows' => [
                                  { 'column1' => 'row1-c1', 'column2' => 'row1-c2', 'column3' => true , 'column4' => 'row1-c4' },
                                  { 'column1' => nil, 'column2' => nil, 'column3' => false, 'column4' => 'CUSTOM VALUE' }
                                ]
                              },
                              'another_table' => {
                                'fields' => [
                                  { 'name' => 'column1', 'type' => 'string', 'default' => nil },
                                  { 'name' => 'column2', 'type' => 'string', 'default' => nil }
                                ],
                                'rows' => [
                                  { 'column1' => 'david', 'column2' => nil },
                                  { 'column1' => nil, 'column2' => 'cruwys' }
                                ]
                              }
                            })
        end
      end
    end
  end

  describe '#data_struct' do
    let(:action) { instance.data_struct }

    before { instance.execute_block }

    context '.settings' do
      subject { action.settings }

      let(:block) do
        lambda do |_|
          settings do
            a 'A'
            b 1
            c true
            d false
          end
        end
      end

      it { expect(subject).to_not be_nil }
      it { expect(subject).to have_attributes(a: 'A', b: 1, c: true, d: false) }
    end

    context '.table' do
      subject { action.table }

      let(:block) do
        lambda do |_|
          table do
            row c1: 'A', c2: 1
            row c1: 'B', c2: true
            row c1: 'C', c2: false
          end
        end
      end

      it { is_expected.to respond_to(:fields) }
      it { is_expected.to respond_to(:rows) }

      context '.fields' do
        subject { action.table.fields }

        it { is_expected.to be_empty }
      end

      context '.rows' do
        subject { action.table.rows }

        it { is_expected.to include(have_attributes(c1: 'A', c2: 1)) }
        it { is_expected.to include(have_attributes(c1: 'B', c2: true)) }
        it { is_expected.to include(have_attributes(c1: 'C', c2: false)) }
      end
    end

    context 'complex - rows and settings' do
      let(:block) do
        lambda do |_|
          settings do
            path '~/somepath'
          end

          c = settings :contact do
            first_name 'david'
            last_name 'cruwys'
          end

          table do
            fields [:column1, f(:column2, 99, :integer), f(:column3, false, :boolean), f(:column4, default: 'CUSTOM VALUE'), f(:column5, '')]

            row 'row1-c1', 66, true, 'row1-c4'
            row
          end

          table :another_table do
            fields %w[column1 column2]

            row column1: c.first_name
            row column2: c.last_name
          end
        end
      end

      context '#debug' do
        it { instance.debug(include_header: true) }
      end

      context '.settings' do
        subject { action.settings }

        it { expect(subject).to_not be_nil }
        it { expect(subject).to have_attributes(path: '~/somepath') }
      end

      context '.contact' do
        subject { action.contact }

        it { expect(subject).to_not be_nil }
        it { expect(subject).to have_attributes(first_name: 'david', last_name: 'cruwys') }
      end

      context '.table' do
        subject { action.table }

        it { is_expected.to respond_to(:fields) }
        it { is_expected.to respond_to(:rows) }

        context '.fields' do
          subject { action.table.fields }

          it { is_expected.not_to be_empty }
          it { is_expected.to include(have_attributes(name: 'column1', default: nil, type: 'string')) }
          it { is_expected.to include(have_attributes(name: 'column2', default: 99, type: 'integer')) }
          it { is_expected.to include(have_attributes(name: 'column3', default: false, type: 'boolean')) }
          it { is_expected.to include(have_attributes(name: 'column4', default: 'CUSTOM VALUE', type: 'string')) }
          it { is_expected.to include(have_attributes(name: 'column5', default: '', type: 'string')) }
        end

        context '.rows' do
          subject { action.table.rows }

          it { is_expected.to include(have_attributes(column1: 'row1-c1', column2: 66, column3: true, column4: 'row1-c4', column5: '')) }
          it { is_expected.to include(have_attributes(column1: nil, column2: 99, column3: false, column4: 'CUSTOM VALUE', column5: '')) }
        end
      end

      context '.another_table' do
        subject { action.another_table }

        it { is_expected.to respond_to(:fields) }
        it { is_expected.to respond_to(:rows) }

        context '.fields' do
          subject { action.another_table.fields }

          it { is_expected.not_to be_empty }
          it { is_expected.to include(have_attributes(name: 'column1', default: nil, type: 'string')) }
          it { is_expected.to include(have_attributes(name: 'column2', default: nil, type: 'string')) }
        end

        context '.rows' do
          subject { action.another_table.rows }

          it { is_expected.to include(have_attributes(column1: 'david', column2: nil)) }
          it { is_expected.to include(have_attributes(column1: nil, column2: 'cruwys')) }
        end
      end
    end
  end

  # describe 'klue.process_code' do

  #   context 'single document' do

  #     subject {
  #       Klue.process_code(
  #         <<-RUBY
  #     Klue::Dsl::DocumentDsl.new 'parent' do
  #       settings do
  #         first_name      'David'
  #         last_name       'Cruwys'
  #       end
  #     end
  #         RUBY
  #       )
  #     }

  #     let(:parent) { Klue.register_instance.get_data('parent')}

  #     it do
  #       subject
  #       expect(parent).to_not be_nil
  #     end
  #     it do
  #       subject
  #       expect(parent).to eq("settings" => { "first_name"=>"David", "last_name"=>"Cruwys" })
  #     end

  #   end

  #   context 'multiple documents' do

  #     subject {
  #       Klue.process_code(
  #         <<-RUBY
  #     Klue::Dsl::DocumentDsl.new 'parent' do
  #       settings do
  #         first_name      'David'
  #         last_name       'Cruwys'
  #       end
  #     end

  #     Klue::Dsl::DocumentDsl.new 'child' do
  #       settings do
  #         age      'Old'
  #         sex      'Male'
  #       end
  #     end
  #       RUBY
  #       )
  #     }

  #     let(:parent) { Klue.register_instance.get_data('parent')}
  #     let(:child) { Klue.register_instance.get_data('child')}

  #     it do
  #       subject
  #       expect(parent).to_not be_nil
  #     end

  #     it do
  #       subject
  #       expect(child).to_not be_nil
  #     end

  #     it do
  #       subject
  #       expect(parent).to eq({"settings"=>{"first_name"=>"David", "last_name"=>"Cruwys"}})
  #     end

  #     it do
  #       subject
  #       expect(child).to eq({"settings"=>{"age"=>"Old", "sex"=>"Male"}})
  #     end

  #   end

  #   context 'multiple documents where child imports from parent' do

  #     subject { Klue.process_code(
  #     <<-RUBY

  #       Klue::Dsl::DocumentDsl.new 'parent' do
  #         settings do
  #           first_name      'David'
  #           last_name       'Cruwys'
  #         end
  #       end

  #       Klue::Dsl::DocumentDsl.new 'child' do

  #         p = import('parent')

  #         settings do
  #           first_name      p.settings.first_name
  #           last_name       p.settings.last_name
  #           age      'Old'
  #           sex      'Male'
  #         end
  #       end

  #     RUBY
  #     ) }

  #     let(:parent) { Klue.register_instance.get_data('parent')}
  #     let(:child) { Klue.register_instance.get_data('child')}

  #     it { subject; expect(parent).to_not be_nil }
  #     it { subject; expect(child).to_not be_nil }
  #     it { subject; expect(parent).to eq({"settings"=>{"first_name"=>"David", "last_name"=>"Cruwys"}}) }
  #     it { subject; expect(child).to eq({"settings"=>{"first_name"=>"David", "last_name"=>"Cruwys", "age"=>"Old", "sex"=>"Male"}}) }

  #   end

  # end
end
