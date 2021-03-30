# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KDoc::Settings do
  let(:data) { {} }

  describe '.key' do
    context 'when no key' do
      subject { described_class.new(data).key }

      it { expect(subject).to eq('settings') }
    end

    context 'when key supplied' do
      subject { described_class.new(data, 'my-key').key }

      it { expect(subject).to eq('my-key') }
    end
  end

  describe '.parent' do
    subject { described_class.new(data, parent: parent).parent }

    context 'when not attached to parent' do
      let(:parent) { nil }

      it 'parent is nil' do
        expect(subject).to be_nil
      end
    end

    # context 'when parent supplied' do
    #   subject { described_class.new(data, parent: parent).parent }

    #   context 'when attached to a parent object' do
    #     let(:parent) { KDoc::Model::Document.new(:x) }

    #     it { expect(subject).not_to be_nil }
    #     it { expect(subject.key).to eq(:x) }
    #     it { expect(subject.type).to eq(:entity) }
    #   end

    #   context 'when accessing dynamic method on parent' do
    #     subject { document }
    #     let(:document) do
    #       KDoc::Model::Document.new do
    #         def its
    #           'crazy'
    #         end

    #         settings do
    #           sanity its
    #         end
    #       end
    #     end

    #     before { subject.execute_block }

    #     it { is_expected.to have_attributes(settings: have_attributes(its: 'crazy'))}
    #   end
    # end
  end

  context 'with setting groups' do
    it 'and key is nil' do
      described_class.new(data)

      expect(data).to eq({ KDoc::FakeOpinion.new.default_settings_key.to_s => {} })
    end

    it 'and key is :key_values' do
      described_class.new(data, :key_values)

      expect(data).to eq({ 'key_values' => {} })
    end

    it 'and key is "key_values"' do
      described_class.new(data, 'key_values')

      expect(data).to eq({ 'key_values' => {} })
    end

    it 'and key is :key_values' do
      described_class.new(data, :key_values)

      expect(data).to eq({ 'key_values' => {} })
    end
  end

  context 'simple setting' do
    subject do
      described_class.new(data) do
        the 'quick'
      end
    end
    # after do
    #   subject.instance_eval do
    #     undef :unknown_attribute if respond_to? :unknown_attribute
    #     undef :unknown_attribute= if respond_to? :unknown_attribute=
    #   end

    #   # described_class.class_eval do
    #   #   remove_method :unknown_attribute if respond_to? :unknown_attribute
    #   #   remove_method :unknown_attribute= if respond_to? :unknown_attribute=
    #   # end
    # end
    describe 'respond_to?' do
      context 'when attribute is used' do
        it 'will respond to getter' do
          expect(subject).to respond_to(:the)
        end
        it 'will respond to setter' do
          expect(subject).to respond_to(:the=)
        end
      end

      context 'when attribute is unknown1' do
        it 'will not respond to getter' do
          expect(subject).not_to respond_to(:unknown1_attribute)
        end
        it 'will not respond to setter' do
          expect(subject).not_to respond_to(:unknown1_attribute=)
        end
      end
    end

    describe 'get attribute value' do
      context 'when attribute already set' do
        it 'will have valid value' do
          expect(subject.the).to eq('quick')
        end
      end

      context 'when attribute is unknown2' do
        it 'will return nil' do
          expect(subject.unknown2_attribute).to be_nil
        end
      end
    end

    describe 'set attribute value' do
      describe 'via setter' do
        context 'when attribute already set' do
          it 'will update the attribute' do
            subject.the = 'slow'
            expect(subject.the).to eq('slow')
          end
        end

        context 'when attribute is unknown' do
          it 'will set the new attribute' do
            subject.unknown3_attribute = 'no so unknown now'
            expect(subject.unknown3_attribute).to eq('no so unknown now')
          end
        end
      end
      describe 'via method' do
        context 'when attribute already set' do
          it 'will update the attribute' do
            subject.the('slow')
            expect(subject.the).to eq('slow')
          end
        end

        context 'when attribute is unknown' do
          it 'will set the new attribute' do
            # subject.unknown_attribute('no so unknown now')
            # expect(subject.unknown_attribute).to eq('no so unknown now')
          end
        end
      end
    end
  end

  context 'setting key/values' do
    it 'no &block' do
      described_class.new(data)

      expect(data).to eq({ 'settings' => {} })
    end

    it 'default limited and get value' do
      dsl = described_class.new(data, :settings) do
        rails_port        3000
        model             'User'
        active            true
      end

      expect(data).to eq({ 'settings' => { 'rails_port' => 3000, 'model' => 'User', 'active' => true } })

      expect(dsl.get_value(:rails_port)).to eq(3000)
      expect(dsl.get_value(:model)).to eq('User')
      expect(dsl.get_value(:active)).to eq(true)
    end

    it 'default full' do
      described_class.new(data, :key_values) do
        rails_port           3000
        model_type           'AdminUser'
        model                'AdminUser'
        models               'AdminUsers'
        main_key             'email'
        note                 'password is an alias to encrypted_password'

        # Can this be in a test data use case object
        td_key1              'super'
        td_key2              'management'
        td_key3              'engineering'
        td_query             %w[01 02 03 04 10 11 12 13]
      end

      expect(data).to eq('key_values' =>
        {
          'rails_port' => 3000,
          'model_type' => 'AdminUser',
          'model' => 'AdminUser',
          'models' => 'AdminUsers',
          'main_key' => 'email',
          'note' => 'password is an alias to encrypted_password',
          'td_key1' => 'super',
          'td_key2' => 'management',
          'td_key3' => 'engineering',
          'td_query' => %w[01 02 03 04 10 11 12 13]
        })
    end
  end

  context 'setting get values by key' do
    subject do
      described_class.new(data, :settings) do
        rails_port        3000
        model             'User'
        active            true
      end
    end

    it 'get value by symbol' do
      expect(subject.get_value(:rails_port)).to eq(3000)
      expect(subject.get_value(:model)).to eq('User')
      expect(subject.get_value(:active)).to eq(true)
    end

    it 'get value by string' do
      expect(subject.get_value('rails_port')).to eq(3000)
      expect(subject.get_value('model')).to eq('User')
      expect(subject.get_value('active')).to eq(true)
    end

    it 'get value by attr_reader' do
      expect(subject.rails_port).to eq(3000)
      expect(subject.model).to eq('User')
      expect(subject.active).to eq(true)
    end
  end

  describe 'error handling' do
    context 'multiple setting values from &block' do
      subject { described_class.new(data) { multiple_x(1, 2) } }

      it { expect { subject }.to raise_error(KDoc::Error) }
    end

    context 'multiple setting values from attribute' do
      subject { described_class.new(data) }

      it { expect { subject.multiple_y(1, 2) }.to raise_error(KDoc::Error) }
    end
  end
end
