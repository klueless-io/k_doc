# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KDoc::HashContainer do
  subject { instance }

  let(:data) { nil }
  let(:instance) { described_class.new(data: data) }

  describe '#constructor' do
    context '.data' do
      subject { instance.data }

      it { is_expected.to eq({}) }
    end

    context 'with incompatible custom data option' do
      let(:data) { [] }

      context '.errors' do
        subject { instance.errors }

        it { is_expected.to include('Incompatible data type - Hash is incompatible with Array') }
        # it { instance.debug }
      end
    end
  end
end
