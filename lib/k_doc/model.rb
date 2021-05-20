# frozen_string_literal: true

module KDoc
  # Model is a DSL for modeling general purpose data objects
  #
  # A mode can have
  #  - 0 or more named setting groups each with their key/value pairs
  #  - 0 or more named table groups each with their own columns and rows
  #
  # A settings group without a name will default to name: :settings
  # A table group without a name will default to name: :table
  class Model < KDoc::Container
    include KLog::Logging

    # include KType::Error
    # include KType::ManagedState
    # include KType::NamedFolder
    # include KType::LayeredFolder

    attr_reader :options

    # Create document
    #
    # @param [String|Symbol] name Name of the document
    # @param args[0] Type of the document, defaults to KDoc:: FakeOpinion.new.default_model_type if not set
    # @param default: Default value (using named params), as above
    def initialize(key = nil, **options, &block)
      super(key: key, type: options[:type] || KDoc.opinion.default_model_type) # , namespace: options[:namespace], project_key: options[:project_key])
      initialize_attributes(**options)

      @block = block if block_given?
    end

    # NOTE: Can this be moved out of the is object?
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
      log.error('Standard error in document')
      # puts "key #{unique_key}"
      # puts "file #{KUtil.data.console_file_hyperlink(resource.file, resource.file)}"
      log.error(e.message)
      @error = e
      # log.exception exception2
      raise
    ensure
      @run_actions = nil
    end

    def settings(key = nil, **options, &block)
      options ||= {}

      opts = {}.merge(@options) # Data Options
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
    # REFACTOR: IT MAY BE BEST TO MOVE raw_data into each of the node_types
    def raw_data
      # REFACT, what if this is CSV, meaning it is just an array?
      #         add specs
      result = data

      result.each_key do |key|
        # ANTI: get_node_type uses @data while we are using @data.clone here
        result[key] = if get_node_type(key) == :table
                        # Old format was to keep the rows and delete the fields
                        # Now the format is to pull the row_value up to the key and remove rows and fields
                        # result[key].delete('fields')
                        result[key]['rows']
                      else
                        result[key]
                      end
      end

      result
    end

    # Move this out to the logger function when it has been refactor
    def debug(include_header: false)
      debug_header if include_header

      # tp dsls.values, :k_key, :k_type, :state, :save_at, :last_at, :data, :last_data, :source, { :file => { :width => 150 } }
      # puts JSON.pretty_generate(data)
      log.o(raw_data_struct)
    end

    def debug_header
      log.heading self.class.name
      log.kv 'key'    , key   , 15
      log.kv 'type'   , type  , 15
      # log.kv 'namespace', namespace
      log.kv 'error'  , error , 15

      debug_header_keys

      log.line
    end

    def debug_header_keys
      options&.keys&.reject { |k| k == :namespace }&.each do |key|
        log.kv key, options[key]
      end
    end

    private

    def initialize_attributes(**options)
      @options    = options || {}
      # Is parent a part of model, or is it part of k_manager::document_taggable
      @parent     = slice_option(:parent)

      # Most documents live within a hash, some tabular documents such as CSV will use an []
      @data       = slice_option(:default_data) || {}
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
