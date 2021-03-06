# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KDoc::YamlDoc do
  subject { instance }

  let(:instance) { described_class.new('some_name', &block) }
  let(:block) { nil }

  describe '.key' do
    subject { instance.key }

    it { is_expected.to eq('some_name') }
  end

  describe '.type' do
    subject { instance.type }

    it { is_expected.to eq(KDoc.opinion.default_yaml_type) }
  end

  describe '.data' do
    subject { instance.data }

    it { is_expected.to eq({}) }
  end

  context 'when valid yaml file using LIST syntax' do
    let(:file) { 'spec/samples/sample-yaml-list.yaml' }

    context 'when not loaded' do
      let(:instance) do
        described_class.new(file: file)
      end

      describe '.file' do
        subject { instance.file }

        it { is_expected.to eq 'spec/samples/sample-yaml-list.yaml' }
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

    context 'when load is called from the main block (fire_eval is enough)' do
      context 'when load' do
        let(:instance) do
          described_class.new(file: file, data: [{ zzz: :yyy }], default_data_type: Array) do
            load
          end
        end
        let(:sample_data) { YAML.safe_load(File.read(file)) }

        before do
          instance.fire_eval
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
          described_class.new(file: file, data: [{ zzz: :yyy }], default_data_type: Array) do
            load(data_action: :append)
          end
        end
        let(:sample_data) { YAML.safe_load(File.read(file)) }

        before do
          instance.fire_eval
        end

        context '.data' do
          subject { instance.data }

          it { is_expected.to eq([{ zzz: :yyy }] + sample_data) }
        end
      end
    end
  end

  context 'when valid yaml file using OBJECT syntax' do
    let(:file) { 'spec/samples/sample-yaml-object.yaml' }

    context 'when not loaded' do
      let(:instance) do
        described_class.new(file: file)
      end

      describe '.file' do
        subject { instance.file }

        it { is_expected.to eq 'spec/samples/sample-yaml-object.yaml' }
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

    context 'when loading using the init hook (fire_eval and fire_init is required)' do
      context 'when loaded' do
        let(:instance) do
          described_class.new(file: file, data: { zzz: :yyy }, default_data_type: Hash) do
            init do
              load
            end
          end
        end
        let(:sample_data) { YAML.safe_load(File.read(file)) }

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
          described_class.new(file: file, data: { zzz: :yyy }, default_data_type: Hash) do
            init do
              load(data_action: :append)
            end
          end
        end
        let(:sample_data) { YAML.safe_load(File.read(file)) }

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
end
