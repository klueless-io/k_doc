# frozen_string_literal: true

require 'spec_helper'

class TestBlock
  include KDoc::BlockProcessor

  attr_reader :context
  attr_reader :some_attribute

  def initialize(**opts, &block)
    @context = OpenStruct.new
    @some_attribute = :the_initial_value_of_some_attribute
    initialize_block_processor(opts, &block)
  end

  # dealing with simple child procs
  def custom(&block)
    add_child(block) if block_given?
  end
end

RSpec.describe KDoc::BlockProcessor do
  include KLog::Logging

  subject { instance }

  describe TestBlock do
    let(:opts) { {} }

    context 'when no block_given?' do
      let(:instance) { described_class.new(**opts) }

      it { expect(instance).to be_new }
      it { expect(instance).not_to be_evaluated }
      it { expect(instance).not_to be_initialized }
      it { expect(instance).not_to be_children_evaluated }
      it { expect(instance).not_to be_actioned }

      describe '.block' do
        subject { instance.block }

        it { is_expected.to be_nil }
      end

      describe '.block_state' do
        subject { instance.block_state }

        it { is_expected.to eq(:new) }
      end

      describe '.init_block' do
        subject { instance.init_block }

        it { is_expected.to be_nil }
      end

      describe '.action_block' do
        subject { instance.action_block }

        it { is_expected.to be_nil }
      end

      describe '.action_block' do
        subject { instance.action_block }

        it { is_expected.to be_nil }
      end

      describe '.child_blocks' do
        subject { instance.child_blocks }

        it { is_expected.to be_empty }
      end

      describe '.some_attribute' do
        subject { instance.some_attribute }

        it { is_expected.to eq(:the_initial_value_of_some_attribute) }
      end
    end

    context 'when block_given?' do
      let(:instance) do
        described_class.new(**opts) do
          @some_attribute = :altered_during_the_main_block_evaluation

          init do
            context.some_data = :set_during_init
            @some_attribute = :altered_during_initialization
          end

          custom do
            context.custom1 = 'custom1'
            @some_attribute = :altered_during_child_block_evaluation_1st
          end

          custom do
            context.custom2 = 'custom2'
            context.custom3 = 'custom3'
            @some_attribute = :altered_during_child_block_evaluation_2nd
          end

          action do
            context.custom1 = 'action: custom1'
            context.custom2 = 'action: custom2'
            context.custom3 = 'action: custom3'
            @some_attribute = :final_action
          end
        end
      end

      context 'before fire_eval' do
        it { expect(instance).to be_new }
        it { expect(instance).not_to be_evaluated }
        it { expect(instance).not_to be_initialized }
        it { expect(instance).not_to be_children_evaluated }
        it { expect(instance).not_to be_actioned }

        describe '.some_attribute' do
          subject { instance.some_attribute }

          it { is_expected.not_to be_nil }
        end

        describe '.some_attribute' do
          subject { instance.some_attribute }

          it { is_expected.to eq(:the_initial_value_of_some_attribute) }
        end

        describe '.context' do
          subject { instance.context }

          it { is_expected.to be_a(OpenStruct) }

          it do
            is_expected.not_to respond_to(:some_data)
            is_expected.not_to respond_to(:custom1)
            is_expected.not_to respond_to(:custom2)
            is_expected.not_to respond_to(:custom3)
          end
        end

        describe '.block' do
          subject { instance.block }

          it { is_expected.not_to be_nil }
        end

        describe '.block_state' do
          subject { instance.block_state }

          it { is_expected.to eq(:new) }
        end

        describe '.init_block' do
          subject { instance.init_block }

          it { is_expected.to be_nil }
        end

        describe '.action_block' do
          subject { instance.action_block }

          it { is_expected.to be_nil }
        end

        describe '.child_blocks' do
          subject { instance.child_blocks }

          it { is_expected.to be_empty }
        end
      end

      context 'after fire_eval' do
        before do
          instance.fire_eval
        end

        it { expect(instance).not_to be_new }
        it { expect(instance).to be_evaluated }
        it { expect(instance).not_to be_initialized }
        it { expect(instance).not_to be_children_evaluated }
        it { expect(instance).not_to be_actioned }

        describe '.some_attribute' do
          subject { instance.some_attribute }

          it { is_expected.to eq(:altered_during_the_main_block_evaluation) }
        end

        describe '.context' do
          subject { instance.context }

          it { is_expected.to be_a(OpenStruct) }

          it do
            is_expected.not_to respond_to(:some_data)
            is_expected.not_to respond_to(:custom1)
            is_expected.not_to respond_to(:custom2)
            is_expected.not_to respond_to(:custom3)
          end
        end

        describe '.block_state' do
          subject { instance.block_state }

          it { is_expected.to eq(:evaluated) }
        end

        describe '.init_block' do
          subject { instance.init_block }

          it { is_expected.not_to be_nil }
        end

        describe '.action_block' do
          subject { instance.action_block }

          it { is_expected.not_to be_nil }
        end

        describe '.child_blocks' do
          subject { instance.child_blocks }

          it { is_expected.not_to be_empty }
        end
      end

      context 'after fire_init' do
        before do
          instance.fire_eval
          instance.fire_init
        end

        it { expect(instance).not_to be_new }
        it { expect(instance).to be_evaluated }
        it { expect(instance).to be_initialized }
        it { expect(instance).not_to be_children_evaluated }
        it { expect(instance).not_to be_actioned }

        describe '.some_attribute' do
          subject { instance.some_attribute }

          it { is_expected.to eq(:altered_during_initialization) }
        end

        describe '.context' do
          subject { instance.context }

          it { is_expected.to have_attributes(some_data: :set_during_init) }

          it do
            is_expected.not_to respond_to(:custom1)
            is_expected.not_to respond_to(:custom2)
            is_expected.not_to respond_to(:custom3)
          end
        end

        describe '.block_state' do
          subject { instance.block_state }

          it { is_expected.to eq(:initialized) }
        end

        describe '.init_block' do
          subject { instance.init_block }

          it { is_expected.not_to be_nil }
        end

        describe '.action_block' do
          subject { instance.action_block }

          it { is_expected.not_to be_nil }
        end

        describe '.child_blocks' do
          subject { instance.child_blocks }

          it { is_expected.not_to be_empty }
        end
      end

      context 'after fire_children_eval' do
        before do
          instance.fire_eval
          instance.fire_init
          instance.fire_children_eval
        end

        it { expect(instance).not_to be_new }
        it { expect(instance).to be_evaluated }
        it { expect(instance).to be_initialized }
        it { expect(instance).to be_children_evaluated }
        it { expect(instance).not_to be_actioned }

        describe '.some_attribute' do
          subject { instance.some_attribute }

          it { is_expected.to eq(:altered_during_child_block_evaluation_2nd) }
        end

        describe '.context' do
          subject { instance.context }

          it do
            is_expected.to have_attributes(
              some_data: :set_during_init,
              custom1: 'custom1',
              custom2: 'custom2',
              custom3: 'custom3'
            )
          end
        end

        describe '.block_state' do
          subject { instance.block_state }

          it { is_expected.to eq(:children_evaluated) }
        end

        describe '.init_block' do
          subject { instance.init_block }

          it { is_expected.not_to be_nil }
        end

        describe '.action_block' do
          subject { instance.action_block }

          it { is_expected.not_to be_nil }
        end

        describe '.child_blocks' do
          subject { instance.child_blocks }

          it { is_expected.not_to be_empty }
        end

        describe '.context.some_data' do
          subject { instance.context.some_data }

          it { is_expected.to eq(:set_during_init) }
        end
      end

      context 'after fire_action' do
        before do
          instance.fire_eval
          instance.fire_init
          instance.fire_children_eval
          instance.fire_action
        end

        it { expect(instance).not_to be_new }
        it { expect(instance).to be_evaluated }
        it { expect(instance).to be_initialized }
        it { expect(instance).to be_children_evaluated }
        it { expect(instance).to be_actioned }

        describe '.some_attribute' do
          subject { instance.some_attribute }

          it { is_expected.to eq(:final_action) }
        end

        describe '.context' do
          subject { instance.context }

          it do
            is_expected.to have_attributes(
              some_data: :set_during_init,
              custom1: 'action: custom1',
              custom2: 'action: custom2',
              custom3: 'action: custom3'
            )
          end
        end

        describe '.block_state' do
          subject { instance.block_state }

          it { is_expected.to eq(:actioned) }
        end

        describe '.init_block' do
          subject { instance.init_block }

          it { is_expected.not_to be_nil }
        end

        describe '.action_block' do
          subject { instance.action_block }

          it { is_expected.not_to be_nil }
        end

        describe '.child_blocks' do
          subject { instance.child_blocks }

          it { is_expected.not_to be_empty }
        end

        describe '.context.some_data' do
          subject { instance.context.some_data }

          it { is_expected.to eq(:set_during_init) }
        end
      end
    end
  end
end
