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
    subject { OpenStruct.new(instance.data) }

    before do
      instance.fire_eval
    end

    context 'when settings blocks' do
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

          # table :custom do
          #   # A table under with the name: :custom
          # end
        end
      end

      it do
        is_expected.to have_attributes(settings: {}, key_values: {})
      end
    end
  end
end
