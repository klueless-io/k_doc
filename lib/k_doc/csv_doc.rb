# frozen_string_literal: true

require 'csv'

module KDoc
  # CsvDoc is a DSL for modeling CSV data objects
  class CsvDoc < KDoc::Container
    attr_reader :file

    # Create CSV document
    #
    # @param [String|Symbol] name Name of the document
    # @param args[0] Type of the document, defaults to KDoc:: FakeOpinion.new.default_csv_type if not set
    # @param default: Default value (using named params), as above
    def initialize(key = nil, **opts, &block)
      super(**{ key: key }.merge(opts))

      initialize_file

      @block = block if block_given?
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

      rows = []

      CSV.foreach(file, headers: true, header_converters: :symbol) do |row|
        rows << row.to_h
      end

      set_data(rows, data_action: data_action)

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
      Array
    end

    def default_container_type
      :csv
    end
  end
end
