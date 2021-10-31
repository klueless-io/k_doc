# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KDoc::Container do
  subject { instance }

  describe '#constructor' do
    context 'with tag and custom options' do
      let(:project) { :spaceman }
      let(:namespace) { %i[app admin controllers] }
      let(:type) { :controller }
      let(:key) { 'some_name' }
      let(:data) { nil }

      let(:instance) do
        described_class.new(key: key,
                            type: type,
                            namespace: namespace,
                            project: project,
                            data: data,
                            other1: 123,
                            other2: :xyz)
      end

      it {
        is_expected.to have_attributes(key: 'some_name',
                                       type: :controller,
                                       namespace: %i[app admin controllers],
                                       project: :spaceman,
                                       tag: :spaceman_app_admin_controllers_controller_some_name,
                                       opts: { other1: 123, other2: :xyz })
      }

      context '.opts' do
        subject { instance.opts }

        it { is_expected.to include(other1: 123, other2: :xyz) }
      end

      context '.data' do
        subject { instance.data }

        it { is_expected.to eq({}) }
      end

      context 'with custom data option' do
        let(:data) { { thunderbirds: :are_go } }

        it {
          is_expected.to have_attributes(key: 'some_name',
                                         type: :controller,
                                         namespace: %i[app admin controllers],
                                         project: :spaceman,
                                         tag: :spaceman_app_admin_controllers_controller_some_name,
                                         opts: { other1: 123, other2: :xyz })
        }

        context '.opts' do
          subject { instance.opts }

          it { is_expected.to include(other1: 123, other2: :xyz) }
        end

        context '.data' do
          subject { instance.data }

          it { is_expected.to eq(data) }
        end
      end

      context 'with incompatible custom data option' do
        let(:data) { [] }

        context '.errors' do
          subject { instance.errors }

          it { is_expected.to include('Incompatible data type - Hash is incompatible with Array') }
          # it { instance.debug }
        end
      end

      context '#block_processor' do
        subject { instance.data }

        let(:instance) do
          described_class.new do
            @data = 'executed'
            def on_action
              @data = 'action has run'
            end
          end
        end

        context 'when execute_block' do
          before { instance.execute_block }
          it { is_expected.to eq('executed') }
        end

        context 'when execute_block' do
          before { instance.execute_block(run_actions: true) }
          it { is_expected.to eq('action has run') }
        end
      end
    end
  end
end
