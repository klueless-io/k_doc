# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KDoc::JsonDoc do
  subject { instance }

  let(:instance) { described_class.new('some_name', &block) }
  let(:block) { nil }

  describe '.key' do
    subject { instance.key }

    it { is_expected.to eq('some_name') }
  end

  describe '.type' do
    subject { instance.type }

    it { is_expected.to eq(KDoc.opinion.default_json_type) }
  end

  describe '.data' do
    subject { instance.data }

    it { is_expected.to eq({}) }
  end

  context 'when valid json file' do
    let(:file) { 'spec/samples/sample.json' }

    context 'when not loaded' do
      let(:instance) do
        described_class.new(file: file)
      end

      describe '.file' do
        subject { instance.file }

        it { is_expected.to eq 'spec/samples/sample.json' }
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
        described_class.new(file: file, data: { zzz: :yyy }) do
          init do
            load
          end
        end
      end
      let(:sample_data) { JSON.parse(File.read(file)) }

      before do
        instance.fire_eval
        instance.fire_init
      end

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
        described_class.new(file: file, data: { zzz: :yyy }) do
          init do
            load(data_action: :append)
          end
        end
      end
      let(:sample_data) { JSON.parse(File.read(file)) }

      before do
        instance.fire_eval
        instance.fire_init
      end

      context '.data' do
        subject { instance.data }

        it { is_expected.to eq({ zzz: :yyy }.merge(sample_data)) }
      end
    end
  end
end
