# frozen_string_literal: true

module KDoc
  # JsonDoc is a DSL for modeling JSON data objects
  class JsonDoc < KDoc::Container
    attr_reader :file

    # Create JSON document
    #
    # @param [String|Symbol] name Name of the document
    # @param args[0] Type of the document, defaults to KDoc:: FakeOpinion.new.default_csv_type if not set
    # @param default: Default value (using named params), as above
    # @param [Proc] block The block is stored and accessed different types in the document loading workflow.
    def initialize(key = nil, **opts, &_block)
      super(**{ key: key }.merge(opts))

      initialize_file
    end

    # Load data from file
    #
    # @param [Symbol] load_action The load_action to take if data has already been loaded
    # @param [:once] load_action :once will load the data from content source on first try only
    # @param [:reload] load_action :reload will reload from content source each time
    # @param [Symbol] data_action The data_action to take when setting data, defaults to :replace
    # @param [:replace] data_action :replace will replace the existing data instance with the incoming data value
    # @param [:append] data_action :append will keep existing data and then new value data over the top
    def load(load_action: :once, data_action: :replace)
      return if load_action == :once && loaded?

      content = File.read(file)
      hash = JSON.parse(content)

      set_data(hash, data_action: data_action)

      @loaded = true
    end

    def loaded?
      @loaded
    end

    private

    def initialize_file
      @file ||= opts.delete(:file) || ''
      @loaded = false
    end

    def default_data_type
      Hash
    end

    def default_container_type
      :json
    end
  end
end
