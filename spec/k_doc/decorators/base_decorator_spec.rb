# frozen_string_literal: true

require 'spec_helper'

# require 'active_support/core_ext/string'

require 'mocks/model_account'
require 'mocks/model_info'
require 'mocks/model_info_decorator'
require 'mocks/model_info_not_implemented_decorator'
require 'mocks/alter_key_values_settings_decorator'
require 'mocks/alter_structure_settings_decorator'
require 'mocks/model_plural_settings_decorator'
require 'mocks/set_db_type_table_decorator'
require 'mocks/set_entity_fields_table_decorator'

# def new_decorator(data, decorator)
#   decorator.new(data)
# end

RSpec.describe KDoc::Decorators::BaseDecorator do
  let(:data) { {} }

  describe '#initialize' do
    subject { instance }

    context 'when base decorator' do
      let(:instance) { KDoc::Decorators::BaseDecorator.new(compatible_type) }
      let(:compatible_type) { Object }

      it { is_expected.not_to be_nil }

      context '.compatible_type' do
        subject { instance.compatible_type }
      
        it { is_expected.to eq(Object) }
      end

      context '.available_behaviors' do
        subject { instance.available_behaviors }
      
        it { is_expected.to eq([:default]) }
      end

      context '.implemented_behaviors' do
        subject { instance.implemented_behaviors }
      
        it { is_expected.to be_empty }
      end
    end

    context 'when simple decorator' do
      let(:instance) { ModelInfoDecorator.new }

      it { is_expected.not_to be_nil }
      
      context '.compatible_type' do
        subject { instance.compatible_type }
      
        it { is_expected.to eq(ModelInfo) }
      end

      context '.available_behaviors' do
        subject { instance.available_behaviors }
      
        it { is_expected.to eq([:default]) }
      end

      context '.implemented_behaviors' do
        subject { instance.implemented_behaviors }
      
        it { is_expected.to eq([:default]) }
      end
    end
  end

  describe '#compatible?' do
    subject { instance.compatible?(target) }

    context 'when compatible with any object' do
      let(:instance) { KDoc::Decorators::BaseDecorator.new(Object) }

      context 'when Hash' do
        let(:target) { {} }

          it { is_expected.to be_truthy }
      end

      context 'when String' do
        let(:target) { 'blah' }

        it { is_expected.to be_truthy }
      end
    end

    context 'when compatible with specific object' do
      let(:instance) { ModelInfoDecorator.new }

      context 'when Hash' do
        let(:target) { {} }

        it { is_expected.to be_falsey }
      end

      context 'when ModelInfo' do
        let(:target) { ModelInfo.new }

        it { is_expected.to be_truthy }
      end

      context 'when ModelAccount (descendant class)' do
        let(:target) { ModelAccount.new }

        it { is_expected.to be_truthy }
      end
    end
  end

  context '#decorate' do
    subject { decorator.decorate(data) }

    context 'when data is incompatible with the decorator' do
      let(:data) { {} }
      let(:decorator) { ModelInfoDecorator.new }

      it { expect { subject }.to raise_error(KType::Error, 'ModelInfoDecorator is incompatible with data object') }
    end

    context 'when decorator has not implemented an update method' do
      let(:data) { ModelInfo.new }
      let(:decorator) { ModelInfoNotImplementedDecorator.new }

      it { expect { subject }.to raise_error(KType::Error, 'ModelInfoNotImplementedDecorator has not implemented an update method') }
    end

    context 'when data is compatible' do
      let(:data) { ModelInfo.new }
      let(:decorator) { ModelInfoDecorator.new }

      it { is_expected.to eq(data) }
    end
  end

  context 'what behaviors can be performed' do

    describe '#behaviors' do
      subject { instance.behaviors }

      context 'when any behavior' do
        let(:instance) { ModelInfoDecorator.new }

        it { is_expected.to include(:all) }
      end

      context 'when decorator has a specific behavior #1' do
        let(:instance) { SetEntityFieldsTableDecorator.new }

        it { is_expected.to include(:update_fields) }
      end

      context 'when decorator has a specific behavior #2' do
        let(:instance) { SetDbTypeTableDecorator.new }

        it { is_expected.to include(:update_rows) }
      end
    end

    describe '#has_behavior?' do
      subject { instance.has_behavior?(behaviors) }

      context 'when any behavior' do
        let(:instance) { ModelInfoDecorator.new }
        let(:behaviors) { :all }

        it { is_expected.to be_truthy }
      end

      context 'when decorator has a specific behavior #1' do
        let(:instance) { SetEntityFieldsTableDecorator.new }

        context 'has update_fields' do
          let(:behaviors) { :update_fields }
          it { is_expected.to be_truthy }
        end

        context 'has update_rows' do
          let(:behaviors) { :update_rows }
          it { is_expected.to be_falsey }
        end
      end
    end
  end

  context 'sample decorators for settings' do
    subject { decorator.decorate(data).internal_data }

    context 'AlterKeyValuesSettingsDecorator' do
      let(:decorator) { AlterKeyValuesSettingsDecorator.new }

      let(:data) do
        KDoc::Settings.new({}) do
          first_name 'David'
          last_name 'Cruwys'
          age 40
        end
      end

      it do
        is_expected.to include(
          'first_name' => 'Dave',
          'last_name' => 'was here',
          'age' => 40,
          'full_name' => 'Dave was here'
        )
      end
    end

    context 'AlterStructureSettingsDecorator' do
      let(:decorator) { AlterStructureSettingsDecorator.new }

      let(:data) do
        KDoc::Settings.new({}) do
          full_name 'David Cruwys'
        end
      end

      it { is_expected.to include('funny_name' => 'david cruwys') }
    end
  end

  context 'sample decorators for table' do
    context 'alter rows - SetDbTypeTableDecorator' do
      subject { decorator.decorate(data, :update_rows).get_rows }

      let(:decorator) { SetDbTypeTableDecorator.new }

      let(:data) do
        KDoc::Table.new({}) do
          fields :name, f(:type, :string), :db_type

          row :full_name
          row :address, db_type: 'TEXT'
          row :age, :int
        end
      end

      it do
        expected = [
          {
            'name' => 'full_name',
            'type' => 'string',
            'db_type' => 'VARCHAR'
          },
          {
            'name' => 'address',
            'type' => 'string',
            'db_type' => 'TEXT'
          },
          {
            'name' => 'age',
            'type' => 'int',
            'db_type' => 'INTEGER'
          }
        ]

        is_expected.to eq(expected)
      end
    end

    context 'alter fields - TableSetEntityFields' do
      subject { decorator.decorate(data, :fields).get_fields }

      let(:decorator) { SetEntityFieldsTableDecorator.new }

      let(:data) do
        KDoc::Table.new({})
      end

      it do
        expected = [
          {
            'name' => 'name',
            'default' => nil,
            'type' => 'string'
          },
          {
            'name' => 'type',
            'default' => 'string',
            'type' => 'string'
          },
          {
            'name' => 'db_type',
            'default' => 'VARCHAR',
            'type' => 'string'
          }
        ]

        is_expected.to eq(expected)
      end
    end
  end

  context 'auto configure via decorators[]' do
    context 'sample decorators for settings' do
      subject { data.internal_data }

      context 'sample 1' do
        let(:data) do
          KDoc::Settings.new({}, decorators: [ModelPluralSettingsDecorator]) do # , :uppercase]) do
            model             'user'
            rails_port        3000
            active            true
          end
        end

        it do
          is_expected.to include(
            'model' => 'user',
            'model_plural' => 'users',
            'rails_port' => 3000,
            'active' => true
          )
        end
      end

      context 'sample 2' do
        let(:data) do
          KDoc::Settings.new({}, decorators: [AlterKeyValuesSettingsDecorator, AlterStructureSettingsDecorator]) do
            first_name 'David'
            last_name 'Cruwys'
            age 40
          end
        end

        it do
          is_expected.to include(
            'first_name' => 'Dave',
            'last_name' => 'was here',
            'age' => 40,
            'funny_name' => 'dave was here'
          )
        end
      end
    end

    context 'sample decorators for table' do
      subject { data.internal_data }

      context 'sample 1' do
        let(:data) do
          KDoc::Table.new({}, decorators: [SetDbTypeTableDecorator]) do
            # , SetEntityFieldsTableDecorator
            # inferred via decorators:
            # fields :name, f(:type, :string), f(:db_type, 'VARCHAR')
            fields :name, f(:type, :string), :db_type
            # fields :a, :b, :c

            row :full_name
            row :address, db_type: 'TEXT'
            row :age, :int
          end
        end

        it do
          expected = {
            'fields' => [
              {
                'name' => 'name',
                'default' => nil,
                'type' => 'string'
              },
              {
                'name' => 'type',
                'default' => 'string',
                'type' => 'string'
              },
              {
                'name' => 'db_type',
                'default' => nil,
                'type' => 'string'
              }
            ],
            'rows' => [
              {
                'name' => 'full_name',
                'type' => 'string',
                'db_type' => 'VARCHAR'
              },
              {
                'name' => 'address',
                'type' => 'string',
                'db_type' => 'TEXT'
              },
              {
                'name' => 'age',
                'type' => 'int',
                'db_type' => 'INTEGER'
              }
            ]
          }

          is_expected.to include(expected)
        end
      end
    end
  end
end
