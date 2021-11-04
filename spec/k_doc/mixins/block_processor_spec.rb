# frozen_string_literal: true

require 'spec_helper'

class TestBlock
  include KDoc::BlockProcessor

  attr_reader :some_data

  def initialize(**opts, &block)
    @some_data = { x: :men }
    initialize_block(opts, &block)
  end
end

RSpec.describe KDoc::BlockProcessor do
  subject { instance }

  describe TestBlock do
    let(:opts) { {} }

    context 'when no block_given?' do
      let(:instance) { described_class.new(**opts) }

      describe '.block' do
        subject { instance.block }

        it { is_expected.to be_nil }
      end

      describe '.some_data' do
        subject { instance.some_data }

        it { is_expected.to eq({ x: :men }) }
      end
    end

    context 'when block_given?' do
      let(:instance) do
        described_class.new(**opts) do
          @some_data = { y: :men }

          def on_action
            @some_data = { z: :men }
          end
        end
      end

      describe '.block' do
        subject { instance.block }

        it { is_expected.not_to be_nil }
      end

      describe '.some_data' do
        subject { instance.some_data }

        context 'before eval_block' do
          it { is_expected.to eq({ x: :men }) }

          context 'after eval_block' do
            before { instance.eval_block }

            it { is_expected.to eq({ y: :men }) }

            context 'after run_on_action' do
              before { instance.run_on_action }
              it { is_expected.to eq({ z: :men }) }
            end
          end
        end
      end
    end
  end
end
