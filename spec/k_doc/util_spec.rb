# frozen_string_literal: true

require 'spec_helper'

# Move to KUtil
RSpec.describe KDoc::Util do
  let(:instance) { described_class.new }

  describe '#build_unique_key' do
    subject { instance.build_unique_key(key, nil, namespace) }

    let(:key) { nil }
    let(:namespace) { nil }

    context 'with nil key' do
      it { expect { subject }.to raise_error KDoc::Error }
    end

    context 'with key' do
      let(:key) { 'some_name' }

      it { is_expected.to eq('some_name_entity') }

      context 'containing a space' do
        let(:key) { 'some name' }

        it { expect(subject).to eq("some name_#{KDoc.opinion.default_document_type}") }
      end

      context 'with namespace' do
        let(:namespace) { :spaceman }

        it { expect(subject).to eq("spaceman_some_name_#{KDoc.opinion.default_document_type}") }
      end

      context 'with type' do
        subject { instance.build_unique_key(key, type, namespace) }

        context 'nil' do
          let(:type) { nil }

          it { expect(subject).to eq("some_name_#{KDoc.opinion.default_document_type}") }
        end

        context 'controller' do
          let(:type) { :controller }

          it { expect(subject).to eq('some_name_controller') }

          context 'and with namespace' do
            let(:namespace) { :spaceman }

            it { expect(subject).to eq('spaceman_some_name_controller') }
          end
        end
      end
    end
  end
end
