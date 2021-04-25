# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KDoc::Container do
  subject { instance }

  let(:instance) { described_class.new(key: key) }

  let(:key) { 'some_name' }
  let(:type) { :controller }
  let(:namespace) { :controllers }
  let(:project) { :spaceman }

  describe '#constructor' do
    context 'with no key' do
      let(:instance) { described_class.new }

      it do
        is_expected.to have_attributes(
          key: match(/^[A-Za-z0-9]{4}$/),
          type: be_empty
        )
      end
    end

    context 'with key only' do
      let(:instance) { described_class.new(key: key) }

      it { expect(subject.key).to eq(key) }

      context 'with key and type' do
        let(:instance) { described_class.new(key: key, type: type) }

        it 'type is set' do
          expect(subject.type).to eq(type)
        end

        context 'when type is' do
          subject { instance.type }

          context 'nil' do
            let(:type) { nil }

            it { is_expected.to eq('') } # eq(KDoc.opinion.default_model_type) }
          end

          context ':some_data_type' do
            let(:type) { :some_data_type }

            it { is_expected.to eq(:some_data_type) }
          end
        end
      end
    end
  end

  describe '.data' do
    subject { instance.data }

    context 'with default initializer' do
      it { is_expected.to eq({}) }
    end

    context 'with custom data' do
      let(:instance) { described_class.new(key: key, data: data) }
      let(:data) { { thunderbirds: :are_go } }

      it { is_expected.to eq({ thunderbirds: :are_go }) }

      context 'of type array' do
        let(:data) { %i[thunderbirds are_go] }

        it { is_expected.to eq(%i[thunderbirds are_go]) }
      end

      describe '#data=' do
        let(:data) { { go: :ricky } }
        before { instance.data = (data) }

        describe '.data' do
          subject { instance.data }

          it { is_expected.to eq(data) }
          it { is_expected.not_to equal(data) }
        end
      end
    end
  end
end
