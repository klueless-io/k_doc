# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KDoc::CsvDoc do
  subject { instance }

  let(:instance) { described_class.new('some_name', &block) }
  let(:block) { nil }
  let(:sample_data) { CSV.parse(File.read(file), headers: true, header_converters: :symbol).map(&:to_h) }

  describe '.key' do
    subject { instance.key }

    it { is_expected.to eq('some_name') }
  end

  describe '.type' do
    subject { instance.type }

    it { is_expected.to eq(KDoc.opinion.default_csv_type) }
  end

  describe '.data' do
    subject { instance.data }

    it { is_expected.to eq([]) }
  end

  context 'when valid csv file' do
    let(:file) { 'spec/samples/sample.csv' }

    context 'when not loaded' do
      let(:instance) do
        described_class.new(file: file)
      end

      describe '.file' do
        subject { instance.file }

        it { is_expected.to eq 'spec/samples/sample.csv' }
      end
      describe '.loaded?' do
        subject { instance.loaded? }

        it { is_expected.to be_falsey }
      end
      context '.data' do
        subject { instance.data }

        it { is_expected.to be_empty }
      end
    end

    context 'when loaded' do
      let(:instance) do
        described_class.new(file: file, data: [{ name: 'Lisa', age: 35 }]) do
          load
        end
      end

      before { instance.fire_eval }

      describe '.file' do
        subject { instance.file }

        it { is_expected.to eq(file) }
      end
      describe '.loaded?' do
        subject { instance.loaded? }

        it { is_expected.to be_truthy }
      end
      context '.data' do
        subject { instance.data }

        it { is_expected.to eq(sample_data) }
      end
    end

    context 'when loaded using data_action: :append' do
      let(:instance) do
        described_class.new(file: file, data: [{ name: 'Lisa', age: 35 }]) do
          load(data_action: :append)
        end
      end

      before { instance.fire_eval }

      context '.data' do
        subject { instance.data }

        it { is_expected.to eq([{ name: 'Lisa', age: 35 }] + sample_data) }
      end
    end
  end
end
