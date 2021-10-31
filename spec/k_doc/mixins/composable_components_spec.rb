# frozen_string_literal: true

require 'spec_helper'

module TestComposite
  class ComposableComponentsBase
    include KDoc::ComposableComponents

    def initialize
      @parent = nil
      @components = []
    end
  end

  class ParentComposableComponents < TestComposite::ComposableComponentsBase
    def add_component(component_klass)
      @components << component_klass.new(self)
    end
  end

  class ChildComposableComponents < TestComposite::ComposableComponentsBase
    def initialize(parent)
      super()
      attach_parent(parent)
    end
  end
end

RSpec.describe KDoc::ComposableComponents do
  subject { instance }

  let(:instance) { TestComposite::ComposableComponentsBase.new }

  it { is_expected.to respond_to(:parent) }
  it { is_expected.to respond_to(:attach_parent) }
  it { is_expected.to respond_to(:navigate_parent) }
  it { is_expected.to respond_to(:components) }

  context 'when component is Parent' do
    let(:instance) { parent }

    let(:parent) { TestComposite::ParentComposableComponents.new }

    context '.parent' do
      subject { instance.parent }

      it { is_expected.to be_nil }
    end

    context 'when parent adds child' do
      before { instance.add_component(TestComposite::ChildComposableComponents) }

      context '.components' do
        subject { instance.components }

        it { is_expected.not_to be_nil }
        it { is_expected.to have_attributes(length: 1) }

        context '.parent' do
          subject { instance.parent }

          it { is_expected.to be_nil }
        end

        context '.navigate_parent' do
          subject { instance.navigate_parent }

          it { is_expected.to be_a(TestComposite::ParentComposableComponents) }
          it { is_expected.to eq(parent) }
        end

        context '.root?' do
          subject { instance.root? }

          it { is_expected.to be_truthy }
        end

        context '.components.first' do
          subject { first_component }

          let(:first_component) { instance.components.first }

          it { is_expected.to be_a(TestComposite::ChildComposableComponents) }

          context '.root?' do
            subject { first_component.root? }

            it { is_expected.to be_falsey }
          end

          context '.components.first.parent' do
            subject { first_component.parent }

            it { is_expected.to be_a(TestComposite::ParentComposableComponents) }
            it { is_expected.to eq(parent) }
          end

          context '.components.first.navigate_parent' do
            subject { first_component.navigate_parent }

            it { is_expected.to be_a(TestComposite::ParentComposableComponents) }
            it { is_expected.to eq(parent) }
          end
        end
      end
    end
  end

  context 'when component is ChildComposableComponents' do
    let(:instance) { child }
    let(:parent) { TestComposite::ParentComposableComponents.new }
    let(:child) { TestComposite::ChildComposableComponents.new(parent) }

    context '.parent' do
      subject { instance.parent }

      it { is_expected.not_to be_nil }
      it { is_expected.to be_a(TestComposite::ParentComposableComponents) }
    end

    context '.components' do
      subject { instance.components }

      it { is_expected.not_to be_nil }
      it { is_expected.to have_attributes(length: 0) }
    end
  end
end
