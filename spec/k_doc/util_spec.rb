# frozen_string_literal: true

require 'spec_helper'

# Move to KUtil
RSpec.describe KDoc::Util do
  let(:instance) { described_class.new }

  describe '#build_unique_key' do
    subject { instance.build_unique_key(key, nil, namespace, project) }

    let(:key) { nil }
    let(:namespace) { nil }
    let(:project) { nil }
    let(:def_type) { KDoc.opinion.default_model_type }

    context 'with nil key' do
      it { expect { subject }.to raise_error KDoc::Error }
    end

    context 'with key' do
      let(:key) { 'some_name' }

      it { is_expected.to eq('some-name-entity') }

      context 'containing a space' do
        let(:key) { 'some name' }

        it { is_expected.to eq("some name-#{def_type}") }
      end

      context 'with project' do
        let(:project) { :project1 }

        it { expect(subject).to eq("project1-some-name-#{def_type}") }
      end

      context 'with namespace' do
        let(:namespace) { :spaceman }

        it { expect(subject).to eq("spaceman-some-name-#{def_type}") }

        context 'with project' do
          let(:project) { :project1 }

          it { expect(subject).to eq("project1-spaceman-some-name-#{def_type}") }
        end
      end

      context 'with type' do
        subject { instance.build_unique_key(key, type, namespace) }

        context 'nil' do
          let(:type) { nil }

          it { expect(subject).to eq("some-name-#{def_type}") }
        end

        context 'controller' do
          let(:type) { :controller }

          it { expect(subject).to eq('some-name-controller') }

          context 'and with namespace' do
            let(:namespace) { :spaceman }

            it { expect(subject).to eq('spaceman-some-name-controller') }
          end
        end
      end
    end
  end
end
