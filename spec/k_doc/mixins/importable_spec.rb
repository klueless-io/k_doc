# frozen_string_literal: true

RSpec.describe KDoc::Importable do
  subject { instance }

  context 'where documents include the Importable mixin' do
    context 'when KDoc::Action' do
      let(:instance) { KDoc::Action.new }

      it { is_expected.to respond_to(:initialize_import) }
    end

    context 'when KDoc::Model' do
      let(:instance) { KDoc::Model.new }

      it { is_expected.to respond_to(:initialize_import) }
    end

    context 'when KDoc::CsvDoc' do
      let(:instance) { KDoc::CsvDoc.new }

      it { is_expected.to respond_to(:initialize_import) }
    end

    context 'when KDoc::JsonDoc' do
      let(:instance) { KDoc::JsonDoc.new }

      it { is_expected.to respond_to(:initialize_import) }
    end

    context 'when KDoc::YamlDoc' do
      let(:instance) { KDoc::YamlDoc.new }

      it { is_expected.to respond_to(:initialize_import) }
    end
  end

  describe '#imports' do
    subject { instance.imports }

    context 'when no imports' do
      let(:instance) { KDoc::Action.new }

      it { is_expected.to be_a(OpenStruct) }
    end

    context 'after run on_import' do
      let(:instance) do
        KDoc::Action.new on_import: proc {
          imports.contact = os(first_name: 'John', last_name: 'Doe')
        }
      end

      before { instance.run_on_import }

      it do
        is_expected
          .to have_attributes(contact: an_instance_of(OpenStruct))
          .and have_attributes(contact: have_attributes(first_name: 'John', last_name: 'Doe'))
      end
    end
  end
end
