# frozen_string_literal: true
# # frozen_string_literal: true

# require 'spec_helper'

# # require 'active_support/core_ext/string'

# require 'mocks/set_db_type_table_decorator'
# require 'mocks/set_entity_fields_table_decorator'

# # def new_decorator(data, decorator)
# #   decorator.new(data)
# # end

# RSpec.describe KDoc::Decorators::BaseDecorator do
#   let(:data) { {} }

#   context 'what behaviours can be performed' do
#     describe '#behaviours' do
#       subject { instance.behaviours }

#       context 'when any behaviour' do
#         let(:instance) { ModelInfoDecorator.new }

#         it { is_expected.to include(:all) }
#       end

#       context 'when decorator has a specific behaviour #1' do
#         let(:instance) { SetEntityFieldsTableDecorator.new }

#         it { is_expected.to include(:update_fields) }
#       end

#       context 'when decorator has a specific behaviour #2' do
#         let(:instance) { SetDbTypeTableDecorator.new }

#         it { is_expected.to include(:update_rows) }
#       end
#     end

#     describe '#has_behaviour?' do
#       subject { instance.has_behaviour?(behaviours) }

#       context 'when any behaviour' do
#         let(:instance) { ModelInfoDecorator.new }
#         let(:behaviours) { :all }

#         it { is_expected.to be_truthy }
#       end

#       context 'when decorator has a specific behaviour #1' do
#         let(:instance) { SetEntityFieldsTableDecorator.new }

#         context 'has update_fields' do
#           let(:behaviours) { :update_fields }
#           it { is_expected.to be_truthy }
#         end

#         context 'has update_rows' do
#           let(:behaviours) { :update_rows }
#           it { is_expected.to be_falsey }
#         end
#       end
#     end
#   end

#   context 'sample decorators for settings' do
#     subject { decorator.decorate(data).internal_data }

#     context 'AlterKeyValuesSettingsDecorator' do
#       let(:decorator) { AlterKeyValuesSettingsDecorator.new }

#       let(:data) do
#         KDoc::Settings.new({}) do
#           first_name 'David'
#           last_name 'Cruwys'
#           age 40
#         end
#       end

#       it do
#         is_expected.to include(
#           'first_name' => 'Dave',
#           'last_name' => 'was here',
#           'age' => 40,
#           'full_name' => 'Dave was here'
#         )
#       end
#     end

#     context 'AlterStructureSettingsDecorator' do
#       let(:decorator) { AlterStructureSettingsDecorator.new }

#       let(:data) do
#         KDoc::Settings.new({}) do
#           full_name 'David Cruwys'
#         end
#       end

#       it { is_expected.to include('funny_name' => 'david cruwys') }
#     end
#   end

#   context 'sample decorators for table' do
#     context 'alter rows - SetDbTypeTableDecorator' do
#       subject { decorator.decorate(data, :update_rows).get_rows }

#       let(:decorator) { SetDbTypeTableDecorator.new }

#       let(:data) do
#         KDoc::Table.new({}) do
#           fields :name, f(:type, :string), :db_type

#           row :full_name
#           row :address, db_type: 'TEXT'
#           row :age, :int
#         end
#       end

#       it do
#         expected = [
#           {
#             'name' => 'full_name',
#             'type' => 'string',
#             'db_type' => 'VARCHAR'
#           },
#           {
#             'name' => 'address',
#             'type' => 'string',
#             'db_type' => 'TEXT'
#           },
#           {
#             'name' => 'age',
#             'type' => 'int',
#             'db_type' => 'INTEGER'
#           }
#         ]

#         is_expected.to eq(expected)
#       end
#     end

#     context 'alter fields - TableSetEntityFields' do
#       subject { decorator.decorate(data, :fields).get_fields }

#       let(:decorator) { SetEntityFieldsTableDecorator.new }

#       let(:data) do
#         KDoc::Table.new({})
#       end

#       it do
#         expected = [
#           {
#             'name' => 'name',
#             'default' => nil,
#             'type' => 'string'
#           },
#           {
#             'name' => 'type',
#             'default' => 'string',
#             'type' => 'string'
#           },
#           {
#             'name' => 'db_type',
#             'default' => 'VARCHAR',
#             'type' => 'string'
#           }
#         ]

#         is_expected.to eq(expected)
#       end
#     end
#   end

#   context 'auto configure via decorators[]' do
#     context 'sample decorators for settings' do
#       subject { data.internal_data }

#       context 'sample 1' do
#         let(:data) do
#           KDoc::Settings.new({}, decorators: [ModelPluralSettingsDecorator]) do # , :uppercase]) do
#             model             'user'
#             rails_port        3000
#             active            true
#           end
#         end

#         it do
#           is_expected.to include(
#             'model' => 'user',
#             'model_plural' => 'users',
#             'rails_port' => 3000,
#             'active' => true
#           )
#         end
#       end

#       context 'sample 2' do
#         let(:data) do
#           KDoc::Settings.new({}, decorators: [AlterKeyValuesSettingsDecorator, AlterStructureSettingsDecorator]) do
#             first_name 'David'
#             last_name 'Cruwys'
#             age 40
#           end
#         end

#         it do
#           is_expected.to include(
#             'first_name' => 'Dave',
#             'last_name' => 'was here',
#             'age' => 40,
#             'funny_name' => 'dave was here'
#           )
#         end
#       end
#     end

#     context 'sample decorators for table' do
#       subject { data.internal_data }

#       context 'sample 1' do
#         let(:data) do
#           KDoc::Table.new({}, decorators: [SetDbTypeTableDecorator]) do
#             # , SetEntityFieldsTableDecorator
#             # inferred via decorators:
#             # fields :name, f(:type, :string), f(:db_type, 'VARCHAR')
#             fields :name, f(:type, :string), :db_type
#             # fields :a, :b, :c

#             row :full_name
#             row :address, db_type: 'TEXT'
#             row :age, :int
#           end
#         end

#         it do
#           expected = {
#             'fields' => [
#               {
#                 'name' => 'name',
#                 'default' => nil,
#                 'type' => 'string'
#               },
#               {
#                 'name' => 'type',
#                 'default' => 'string',
#                 'type' => 'string'
#               },
#               {
#                 'name' => 'db_type',
#                 'default' => nil,
#                 'type' => 'string'
#               }
#             ],
#             'rows' => [
#               {
#                 'name' => 'full_name',
#                 'type' => 'string',
#                 'db_type' => 'VARCHAR'
#               },
#               {
#                 'name' => 'address',
#                 'type' => 'string',
#                 'db_type' => 'TEXT'
#               },
#               {
#                 'name' => 'age',
#                 'type' => 'int',
#                 'db_type' => 'INTEGER'
#               }
#             ]
#           }

#           is_expected.to include(expected)
#         end
#       end
#     end
#   end
# end
