# frozen_string_literal: true

require 'spec_helper'

class DatumContainer
  include KDoc::Datum

  def initialize(**opts)
    initialize_data(opts)
  end
end

class DatumContainerHash < DatumContainer
  def default_data_value
    {}
  end
end

class DatumContainerArray < DatumContainer
  def default_data_value
    []
  end
end

RSpec.describe DatumContainerHash do
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

      context 'when data option missing' do
        let(:opts) { {} }

        it { is_expected.to eq({}) }

        describe DatumContainerArray do
          it { is_expected.to eq([]) }
        end
      end
    end
  end
end
