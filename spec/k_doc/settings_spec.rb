# frozen_string_literal: true

require 'spec_helper'

class SettingParent
  attr_reader :some_attribute
end

RSpec.describe KDoc::Settings do
  let(:parent) { SettingParent.new }
  let(:data) { {} }
  let(:instance) { described_class.new(parent, data) }

  describe '.key' do
    subject { instance.key }

    context 'when no key' do
      it { expect(subject).to eq('settings') }
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

  context 'with setting keys' do
    subject { data }

    context 'when key is nil' do
      before { described_class.new(parent, data) }

      it { is_expected.to eq({ 'settings' => {} }) }
    end

    context 'when key is :key_values' do
      before { described_class.new(parent, data, :key_values) }

      it { is_expected.to eq({ 'key_values' => {} }) }
    end

    context 'and key is "key_values"' do
      before { described_class.new(parent, data, 'key_values') }

      it { is_expected.to eq({ 'key_values' => {} }) }
    end
  end

  context 'should populate data' do
    subject { data }

    let(:instance) do
      described_class.new(parent, data, :app_settings) do
        rails_port           3000
        active               true
        model                'AdminUser'
        main_key             'email'
        note                 'password is an alias to encrypted_password'
        td_query             %w[01 02 03 04 10 11 12 13]
      end
    end

    context 'before eval' do
      before { instance }

      it { is_expected.to eq('app_settings' => {}) }

      context 'after eval_block' do
        before { instance.eval_block }

        it do
          is_expected.to eq('app_settings' =>
            {
              'rails_port' => 3000,
              'active' => true,
              'model' => 'AdminUser',
              'main_key' => 'email',
              'note' => 'password is an alias to encrypted_password',
              'td_query' => %w[01 02 03 04 10 11 12 13]
            })
        end
      end
    end
  end

  context 'should respond_to? dynamic getter/setters' do
    subject { instance }

    let(:instance) do
      described_class.new(parent, data) do
        the 'quick'
        brown 'fox'
      end
    end

    context 'before eval' do
      before { instance }

      it { is_expected.not_to respond_to(:the) }
      it { is_expected.not_to respond_to(:the=) }

      context 'after eval_block' do
        before { instance.eval_block }

        it do
          is_expected.to respond_to(:the)
            .and respond_to(:the=)
            .and respond_to(:brown)
            .and respond_to(:brown=)
        end
      end
    end
  end

  context 'should have getter' do
    subject { instance }

    let(:instance) do
      described_class.new(parent, data) do
        my_get1 'quick'
        my_get2 'fox'
      end
    end

    context 'after eval_block' do
      before { instance.eval_block }

      it 'will have valid value' do
        expect(subject.my_get1).to eq('quick')
        expect(subject.my_get2).to eq('fox')
      end

      context 'should have setter' do
        before do
          instance.my_get1 = 'slow'
          instance.my_get2 = 'dog'
        end

        it 'will have valid value' do
          expect(subject.my_get1).to eq('slow')
          expect(subject.my_get2).to eq('dog')
        end
      end

      context 'should be able to dynamically create new setter/getter' do
        before do
          instance.new_attribute = 'new_value'
        end

        it 'will have valid value' do
          expect(subject.new_attribute).to eq('new_value')
        end
      end
    end
  end

  context 'can use get_value using :symbol key' do
    subject { instance }

    let(:instance) do
      described_class.new(parent, data) do
        rails_port        3000
        model             'User'
        active            true
      end
    end

    context 'after eval_block' do
      before { instance.eval_block }

      it 'will have valid value' do
        expect(subject.get_value(:rails_port)).to eq(3000)
        expect(subject.get_value(:model)).to eq('User')
        expect(subject.get_value(:active)).to eq(true)
      end
    end
  end

  describe '#get_value' do
    subject { instance }

    let(:instance) do
      described_class.new(parent, data) do
        rails_port        3000
        model             'User'
        active            true
      end
    end

    before { instance.eval_block }

    context 'when using :symbol key' do
      it { expect(subject.get_value(:rails_port)).to eq(3000) }
      it { expect(subject.get_value(:model)).to eq('User') }
      it { expect(subject.get_value(:active)).to eq(true) }
    end

    context 'when using "string" key' do
      it { expect(subject.get_value('rails_port')).to eq(3000) }
      it { expect(subject.get_value('model')).to eq('User') }
      it { expect(subject.get_value('active')).to eq(true) }
    end
  end
end
