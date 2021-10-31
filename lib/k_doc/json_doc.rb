# frozen_string_literal: true

module KDoc
  # JsonDoc is a DSL for modeling JSON data objects
  class JsonDoc < KDoc::HashContainer

    attr_reader :file

    # Create JSON document
    #
    # @param [String|Symbol] name Name of the document
    # @param args[0] Type of the document, defaults to KDoc:: FakeOpinion.new.default_csv_type if not set
    # @param default: Default value (using named params), as above
    def initialize(key = nil, **opts, &block)
      super(**{ key: key }.merge(opts))

      initialize_csv

      @block = block if block_given?
    end

    def loaded?
      @loaded
    end

    private

    def initialize_csv
      @file ||= opts.delete(:file) || ''
      @loaded = false
    end

    def default_data_value
      {}
    end

    def default_container_type
      :json
    end
  end
end
