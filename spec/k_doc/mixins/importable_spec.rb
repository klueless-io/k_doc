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

    context 'after call importer' do
      let(:instance) do
        KDoc::Action.new importer: lambda { |doc|
          doc.imports.contact = OpenStruct.new(first_name: 'John', last_name: 'Doe')
        }
      end

      before { instance.call_importer }

      it do
        is_expected
          .to have_attributes(contact: an_instance_of(OpenStruct))
          .and have_attributes(contact: have_attributes(first_name: 'John', last_name: 'Doe'))
      end
    end

    # context 'apply sample workflows' do
    #   context 'find document and check imported data' do
    #     subject { KUtil.data.to_open_struct(document.data) }

    #     let(:document) { KManager.find_document(key) }

    #     context 'when simple document' do
    #       let(:key) { :simple_kdoc }

    #       it do
    #         is_expected.to have_attributes(settings:
    #           have_attributes(
    #             me: :simple,
    #             name: 'simple-name',
    #             description: 'simple-description'
    #           ))
    #       end

    #       describe '#import_rules' do
    #         subject { document.import_rules }

    #         it { is_expected.to be_nil }
    #       end
    #     end

    #     fcontext 'when simple document in deep namespace' do
    #       let(:key) { :multi_nested_deep_kdoc }

    #       it do
    #         is_expected.to have_attributes(settings:
    #           have_attributes(
    #             me: :deep,
    #             name: 'deep-name',
    #             description: 'deep-description'
    #           ))
    #       end
    #     end

    #     context 'when document imports from another document' do
    #       let(:key) { :simple_import_kdoc }

    #       it do
    #         is_expected.to have_attributes(settings:
    #           have_attributes(
    #             me: :simple_import,
    #             # name: 'simple-name',
    #             # description: 'simple-description'
    #           ))
    #       end

    #       describe '#import_rules' do
    #         subject { document.import_rules }

    #         it { is_expected.not_to be_nil }
    #       end
    #     end

    #     context 'when document imports from multiple document' do
    #       let(:key) { :multiple_import_kdoc }

    #       it do
    #         is_expected.to have_attributes(from_simple:
    #             have_attributes(
    #               name: 'simple-name',
    #               description: 'simple-description'
    #             ))
    #           .and have_attributes(from_deep:
    #             have_attributes(
    #               name: 'deep-name',
    #               description: 'deep-description'
    #             ))
    #       end
    #     end

    #     context 'when recursion a<->b documents' do
    #       let(:key) { :recursion_a_kdoc }

    #       # it do
    #       #   doc = KManager.area_documents.last
    #       #   doc.debug(include_header: true)
    #       #   # log.error doc.owner.class.name
    #       #   # doc.owner.debug
    #       #   is_expected.to have_attributes(settings:
    #       #     have_attributes(
    #       #       me: :recursion_a,
    #       #       grab: :recursion_b_not_set
    #       #     ))
    #       # end
    #     end
    #   end

    #   def debug
    #     dashboard = KManager::Overview::Dashboard.new(KManager.manager)
    #     # dashboard.areas
    #     # dashboard.resources
    #     dashboard.documents
    #   end
  end
end
