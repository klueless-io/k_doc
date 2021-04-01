# frozen_string_literal: true

module KDoc
  # General purpose document DSL
  #
  # Made up of 0 or more setting groups and table groups
  class Document
    attr_reader :key
    attr_reader :type
    attr_reader :namespace
    attr_reader :options
    attr_reader :error

    # Create document
    #
    # @param [String|Symbol] name Name of the document
    # @param args[0] Type of the document, defaults to KDoc:: FakeOpinion.new.default_document_type if not set
    # @param default: Default value (using named params), as above
    def initialize(key = SecureRandom.alphanumeric(8), **options, &block)
      initialize_attributes(key, **options)

      @block = block if block_given?
    end

    def execute_block(run_actions: nil)
      return if @block.nil?

      # The DSL actions method will only run on run_actions: true
      @run_actions = run_actions

      instance_eval(&@block)

      on_action if run_actions && respond_to?(:on_action)
    # rescue KDoc::Error => e
    #   puts('KDoc::Error in document')
    #   puts "key #{unique_key}"
    #   # puts "file #{KUtil.data.console_file_hyperlink(resource.file, resource.file)}"
    #   puts(e.message)
    #   @error = e
    #   raise
    rescue StandardError => e
      L.error('Standard error in document')
      puts "key #{unique_key}"
      # puts "file #{KUtil.data.console_file_hyperlink(resource.file, resource.file)}"
      L.error(e.message)
      @error = e
      # L.exception exception2
      raise
    ensure
      @run_actions = nil
    end

    def unique_key
      @unique_key ||= KDoc.util.build_unique_key(key, type, namespace)
    end

    def settings(key = nil, **options, &block)
      options ||= {}

      opts = {}.merge(@options) # Document Options
               .merge(options)  # Settings Options
               .merge(parent: self)

      settings_instance(@data, key, **opts, &block)
      # settings.run_decorators(opts)
    end

    def table(key = :table, **options, &block)
      # NEED to add support for run_decorators I think
      options.merge(parent: self)
      table_instance(@data, key, **options, &block)
    end
    alias rows table

    # Sweet add-on would be builders
    # def builder(key, &block)
    #   # example
    #   KDoc::Builder::Shotstack.new(@data, key, &block)
    # end

    # def set_data(data)
    #   @data = data
    # end

    def data
      @data.clone
    end

    def data_struct
      KUtil.data.to_open_struct(data)
    end
    # alias d data_struct

    def raw_data_struct
      KUtil.data.to_open_struct(raw_data)
    end

    def get_node_type(node_name)
      node_name = KUtil.data.clean_symbol(node_name)
      node_data = @data[node_name]

      raise KDoc::Error, "Node not found: #{node_name}" if node_data.nil?

      if node_data.keys.length == 2 && (node_data.key?('fields') && node_data.key?('rows'))
        :table
      else
        :settings
      end
    end

    # Removes any meta data eg. "fields" from a table and just returns the raw data
    def raw_data
      # REFACT, what if this is CSV, meaning it is just an array?
      #         add specs
      result = data

      result.each_key do |key|
        # ANTI: get_node_type uses @data while we are using @data.clone here
        data[key] = if get_node_type(key) == :table
                      result[key].delete('fields')
                    else
                      result[key]
                    end
      end

      data
    end

    # Move this out to the logger function when it has been refactor
    def debug(include_header: false)
      debug_header if include_header

      # tp dsls.values, :k_key, :k_type, :state, :save_at, :last_at, :data, :last_data, :source, { :file => { :width => 150 } }
      # puts JSON.pretty_generate(data)
      L.o(raw_data_struct)
    end

    def debug_header
      L.heading self.class.name
      L.kv 'key', key
      L.kv 'type', type
      L.kv 'namespace', namespace
      L.kv 'error', error

      debug_header_keys

      L.line
    end

    def debug_header_keys
      options&.keys&.reject { |k| k == :namespace }&.each do |key|
        L.kv key, options[key]
      end
    end

    private

    def initialize_attributes(key = nil, **options)
      @key = key

      @options    = options || {}
      @type       = slice_option(:type) || KDoc.opinion.default_document_type
      @namespace  = slice_option(:namespace) || ''
      @parent     = slice_option(:parent)

      # Most documents live within a hash, some tabular documents such as CSV will use an []
      @data       = slice_option(:default_data) || {}

      @error = nil
    end

    def settings_instance(data, key, **options, &block)
      KDoc.opinion.settings_class.new(data, key, **options, &block)
    end

    def table_instance(data, key, **options, &block)
      KDoc.opinion.table_class.new(data, key, **options, &block)
    end

    def slice_option(key)
      return nil unless @options.key?(key)

      result = @options[key]
      @options.delete(key)
      result
    end
  end
end
