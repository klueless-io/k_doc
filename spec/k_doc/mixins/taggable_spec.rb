# frozen_string_literal: true

require 'spec_helper'

class TaggableContainer
  include KDoc::Taggable

  def initialize(**opts)
    initialize_tag(opts)
  end

  def default_container_type
    :some_container
  end
end

RSpec.describe TaggableContainer do
  subject { instance }

  describe '#constructor' do
    let(:key) { nil }
    let(:type) { nil }
    let(:namespace) { nil }
    let(:project) { nil }

    context 'with no options' do
      let(:instance) { described_class.new }

      it do
        is_expected.to have_attributes(
          key: match(/^[A-Za-z0-9]{4}$/),
          type: :some_container,
          namespace: be_empty,
          project: be_empty
        )
      end
    end

    context 'with default options' do
      let(:instance) do
        described_class.new(key: key,
                            type: type,
                            namespace: namespace,
                            project: project)
      end

      it do
        is_expected.to have_attributes(
          key: match(/^[A-Za-z0-9]{4}$/),
          type: :some_container,
          namespace: be_empty,
          project: be_empty
        )
      end

      describe '.tag' do
        subject { instance.tag }

        it { is_expected.to eq("#{instance.key}_#{instance.type}".to_sym) }
      end

      context 'with key (string)' do
        let(:key) { 'some_name' }

        context '.key' do
          subject { instance.key }

          it { is_expected.to eq(key) }
        end

        describe '.tag' do
          subject { instance.tag }

          it { is_expected.to eq("#{instance.key}_#{instance.type}".to_sym) }
        end
      end

      context 'with type (string)' do
        let(:type) { :controller }

        context '.type' do
          subject { instance.type }

          it { is_expected.to eq(type) }
        end

        describe '.tag' do
          subject { instance.tag }

          it { is_expected.to eq("#{instance.key}_#{instance.type}".to_sym) }
        end
      end

      context 'with project (string)' do
        let(:project) { :spaceman }

        context '.project' do
          subject { instance.project }

          it { is_expected.to eq(project) }
        end

        describe '.tag' do
          subject { instance.tag }

          it { is_expected.to eq("#{instance.project}_#{instance.key}_#{instance.type}".to_sym) }
        end
      end

      context 'with namespace (string)' do
        let(:namespace) { :controllers }

        context '.namespace' do
          subject { instance.namespace }

          it { is_expected.to eq([namespace]) }
        end

        describe '.tag' do
          subject { instance.tag }

          it { is_expected.to eq("#{instance.namespace.first}_#{instance.key}_#{instance.type}".to_sym) }
        end
      end

      context 'with namespace (array)' do
        let(:namespace) { %i[app admin controllers] }

        context '.namespace' do
          subject { instance.namespace }

          it { is_expected.to eq(namespace) }
        end

        describe '.tag' do
          subject { instance.tag }

          it { is_expected.to eq("#{instance.namespace.join('_')}_#{instance.key}_#{instance.type}".to_sym) }
        end
      end

      context 'with project, namespaces, type and id' do
        let(:project) { :spaceman }
        let(:namespace) { %i[app admin controllers] }
        let(:type) { :controller }
        let(:key) { 'some_name' }

        context '.namespace' do
          subject { instance.namespace }

          it { is_expected.to eq(namespace) }
        end

        describe '.tag' do
          subject { instance.tag }

          it { is_expected.to eq("#{instance.project}_#{instance.namespace.join('_')}_#{instance.key}_#{instance.type}".to_sym) }
        end

        context 'tag_options.keys are removed after access' do
          it { expect(instance.tag_options.key?(:key)).to be_falsey }
          it { expect(instance.tag_options.key?(:namespace)).to be_falsey }
          it { expect(instance.tag_options.key?(:type)).to be_falsey }
          it { expect(instance.tag_options.key?(:key)).to be_falsey }
        end
      end
    end
  end
end
