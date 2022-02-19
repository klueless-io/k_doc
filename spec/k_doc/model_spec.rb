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

RSpec.describe KDoc::Model do
  subject { instance }

  let(:instance) { described_class.new('some_name', custom: 'blah', &block) }
  let(:block) { nil }

  context '.key' do
    subject { instance.key }

    it { is_expected.to eq('some_name') }
  end

  context '.type' do
    subject { instance.type }

    it { is_expected.to eq(KDoc.opinion.default_model_type) }
  end

  context '.data' do
    subject { instance }

    let(:block) do
      lambda do |_|
        init do
          context.xmen = 'Wolverine'
        end

        settings do
          name 'Some name'
          description 'Some description'
        end

        settings :key_values do
          favourite_mutant context.xmen
          # Some settings with the key: :key_values
        end

        table do
          fields :role

          row :owner
          row :staff
        end

        table :people do
          # A table under with the name: :custom
          fields f(:first_name), f(:role, :symbol, :staff)

          row 'David', :staff
          row 'Ben', :staff
          row context.xmen, :owner
        end
      end
    end

    context 'after fire_eval' do
      before do
        instance.fire_eval
      end

      context '.context' do
        it { expect(subject.context).to be_a(OpenStruct) }

        it { expect(subject.context.xmen).to be_nil }
      end

      context '.settings blocks should be initialized' do
        it 'default block data filled in' do
          expect(subject.data['settings']).to eq({})
          expect(subject.data['key_values']).to eq({})
          expect(subject.data['table']).to eq({ 'fields' => [], 'rows' => [] })
          expect(subject.data['people']).to eq({ 'fields' => [], 'rows' => [] })
        end

        context 'check data' do
          subject { instance.data[key.to_s] }
          context 'when settings' do
            let(:key) { :settings }
            it { is_expected.to eq({}) }
          end
          context 'when key_values' do
            let(:key) { :key_values }
            it { is_expected.to eq({}) }
          end
          context 'when table' do
            let(:key) { :table }
            it { is_expected.to eq({ 'fields' => [], 'rows' => [] }) }
          end
          context 'when people' do
            let(:key) { :people }
            it { is_expected.to eq({ 'fields' => [], 'rows' => [] }) }
          end
          context 'raise error when unknown' do
            let(:key) { :unknown }
            it { is_expected.to be_nil }
          end
        end

        context 'check node_type' do
          subject { instance.get_node_type(key) }
          context 'when using default settings key' do
            let(:key) { :settings }
            it { is_expected.to eq(:settings) }
          end
          context 'when using settings with custom key' do
            let(:key) { :key_values }
            it { is_expected.to eq(:settings) }
          end
          context 'when using default table key' do
            let(:key) { :table }
            it { is_expected.to eq(:table) }
          end
          context 'when using table with custom key' do
            let(:key) { :people }
            it { is_expected.to eq(:table) }
          end

          context 'raise error when node_type is unknown' do
            let(:key) { :unknown }
            it { expect { subject }.to raise_error(KDoc::Error) }
          end
        end
      end
    end

    context 'after fire_eval -> fire_init' do
      before do
        instance.fire_eval
        instance.fire_init
      end

      context '.context' do
        it { expect(subject.context.xmen).to eq('Wolverine') }
      end

      context '.settings blocks' do
        context 'check data' do
          subject { instance.data[key.to_s] }
          context 'when settings' do
            let(:key) { :settings }
            it { is_expected.to eq({}) }
          end
          context 'when key_values' do
            let(:key) { :key_values }
            it { is_expected.to eq({}) }
          end
        end
      end

      context '.tables blocks' do
        context 'check data' do
          subject { instance.data[key.to_s] }
          context 'when table' do
            let(:key) { :table }
            it { is_expected.to eq({ 'fields' => [], 'rows' => [] }) }
          end
          context 'when people' do
            let(:key) { :people }
            it { is_expected.to eq({ 'fields' => [], 'rows' => [] }) }
          end
        end
      end
    end

    context 'after fire_eval -> fire_init -> fire_children' do
      before do
        instance.fire_eval
        instance.fire_init
        instance.fire_children
      end

      context '.context' do
        it { expect(subject.context.xmen).to eq('Wolverine') }
      end

      context '.settings blocks' do
        context 'check data' do
          subject { instance.data[key.to_s] }
          context 'when settings' do
            let(:key) { :settings }
            it do
              is_expected.to eq(
                {
                  'description' => 'Some description',
                  'name' => 'Some name'
                }
              )
            end
          end
          context 'when key_values' do
            let(:key) { :key_values }
            it { is_expected.to eq({ 'favourite_mutant' => 'Wolverine' }) }
          end
        end
      end

      context '.tables blocks' do
        context 'check data' do
          subject { instance.data[key.to_s] }
          context 'when table' do
            let(:key) { :table }
            it do
              is_expected.to eq({
                                  'fields' => [{ 'name' => 'role', 'type' => 'string', 'default' => nil }],
                                  'rows' => [{ 'role' => :owner }, { 'role' => :staff }]
                                })
            end
          end
          context 'when people' do
            let(:key) { :people }
            it do
              is_expected.to eq({
                                  'fields' => [
                                    { 'name' => 'first_name', 'type' => 'string', 'default' => nil },
                                    { 'name' => 'role', 'type' => 'staff', 'default' => 'symbol' }
                                  ],
                                  'rows' => [
                                    { 'first_name' => 'David', 'role' => :staff },
                                    { 'first_name' => 'Ben', 'role' => :staff },
                                    { 'first_name' => 'Wolverine', 'role' => :owner }
                                  ]
                                })
            end
          end
        end
      end
    end
  end
end
