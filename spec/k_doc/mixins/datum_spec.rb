# frozen_string_literal: true

require 'spec_helper'

class DatumContainer
  include KDoc::Datum

  def initialize(**opts)
    initialize_data(opts)
  end
end

class DatumHash < DatumContainer
  def default_data_value
    {}
  end
end

class DatumArray < DatumContainer
  def default_data_value
    []
  end
end

RSpec.describe DatumHash do
  subject { instance }

  let(:opts) { {} }
  let(:instance) { described_class.new(**opts) }

  describe '#constructor' do
    describe '.data' do
      subject { instance.data }

      context 'when option :data' do
        let(:opts) { { data: { x: :men } } }

        it { is_expected.to eq({ x: :men }) }
      end

      context 'when option :default_data' do
        let(:opts) { { default_data: { y: :men } } }

        it { is_expected.to eq({ y: :men }) }
      end

      context 'when data type mismatch' do
        let(:opts) { { data: [1, 2, 3] } }

        it { is_expected.to eq({}) }

        context '.error_messages' do
          subject { instance.error_messages }

          it { is_expected.to include('Incompatible data type - Hash is incompatible with Array') }
        end
      end

      context 'when data option missing' do
        let(:opts) { {} }

        it { is_expected.to eq({}) }
      end
    end
  end

  describe '#clear_data' do
    subject { instance.data }

    let(:opts) { { data: { custom: :data } } }

    it { is_expected.not_to be_empty }

    context 'when clear_data' do
      before { instance.clear_data }

      it { is_expected.to be_empty }
    end
  end

  describe '#set_data' do
    let(:opts) { { data: { custom: :data } } }
    let(:data_action) { {} }

    describe '.data' do
      context 'when (default) data_action' do
        it 'replace old data reference with new data reference' do
          new_data = { hello: :world }

          instance.set_data(new_data, **data_action)

          expect(instance.data).to eq(new_data)
          expect(instance.data).to be(new_data)
        end
      end

      context 'when data_action: :replace - replace old data reference with new data reference' do
        let(:data_action) { { data_action: :replace } }

        it do
          new_data = { hello: :world }

          instance.set_data(new_data, **data_action)

          expect(instance.data).to eq(new_data)
          expect(instance.data).to be(new_data)
        end
      end

      context 'when data_action: :append - existing data reference is kept and then merged with new data' do
        let(:data_action) { { data_action: :append } }

        it do
          new_data = { hello: :world }

          instance.set_data(new_data, **data_action)

          expect(instance.data).to eq({ custom: :data , hello: :world })
          expect(instance.data).not_to be(new_data)
        end
      end

      context 'when clear_data and data_action: :merge - clear existing data first and then merge with new data' do
        let(:data_action) { { data_action: :append } }

        it do
          new_data = { hello: :world }

          instance.clear_data
          instance.set_data(new_data, **data_action)

          expect(instance.data).to eq(new_data)
          expect(instance.data).not_to be(new_data)
        end
      end
    end
  end
end

RSpec.describe DatumArray do
  subject { instance }

  let(:opts) { {} }
  let(:instance) { described_class.new(**opts) }

  describe '#constructor' do
    describe '.data' do
      subject { instance.data }

      context 'when option :data' do
        let(:opts) { { data: [1, 2, 3] } }

        it { is_expected.to eq([1, 2, 3]) }
      end

      context 'when option :default_data' do
        let(:opts) { { default_data: [4, 5, 6] } }

        it { is_expected.to eq([4, 5, 6]) }
      end

      context 'when data type mismatch' do
        let(:opts) { { data: { x: :men } } }

        it { is_expected.to eq([]) }

        context '.error_messages' do
          subject { instance.error_messages }

          it { is_expected.to include('Incompatible data type - Array is incompatible with Hash') }
        end
      end

      context 'when data option missing' do
        let(:opts) { {} }

        it { is_expected.to eq([]) }
      end
    end
  end

  describe '#clear_data' do
    subject { instance.data }

    let(:opts) { { data: [1, 2, 3] } }

    it { is_expected.not_to be_empty }

    context 'when clear_data' do
      before { instance.clear_data }

      it { is_expected.to be_empty }
    end
  end

  describe '#set_data' do
    let(:opts) { { data: [1, 2, 3] } }
    let(:data_action) { {} }

    describe '.data' do
      context 'when (default) data_action' do
        it 'replace old data reference with new data reference' do
          new_data = [4, 5, 6]

          instance.set_data(new_data, **data_action)

          expect(instance.data).to eq(new_data)
          expect(instance.data).to be(new_data)
        end
      end

      context 'when data_action: :replace - replace old data reference with new data reference' do
        let(:data_action) { { data_action: :replace } }

        it do
          new_data = [4, 5, 6]

          instance.set_data(new_data, **data_action)

          expect(instance.data).to eq(new_data)
          expect(instance.data).to be(new_data)
        end
      end

      context 'when data_action: :append - existing data reference is kept and then merged with new data' do
        let(:data_action) { { data_action: :append } }

        it do
          new_data = [4, 5, 6]

          instance.set_data(new_data, **data_action)

          expect(instance.data).to eq([1, 2, 3, 4, 5, 6])
          expect(instance.data).not_to be(new_data)
        end
      end

      context 'when clear_data and data_action: :merge - clear existing data first and then merge with new data' do
        let(:data_action) { { data_action: :append } }

        it do
          new_data = [4, 5, 6]

          instance.clear_data
          instance.set_data(new_data, **data_action)

          expect(instance.data).to eq(new_data)
          expect(instance.data).not_to be(new_data)
        end
      end
    end
  end
end
