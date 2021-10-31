# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KDoc::ArrayContainer do
  subject { instance }

  let(:data) { nil }
  let(:instance) { described_class.new(data: data) }

  describe '#constructor' do
    context '.data' do
      subject { instance.data }

      it { is_expected.to eq([]) }
    end

    context 'with incompatible custom data option' do
      let(:data) { {} }

      context '.errors' do
        subject { instance.errors }

        it { is_expected.to include('Incompatible data type - Array is incompatible with Hash') }
        it { instance.debug }
      end
    end
  end
end
