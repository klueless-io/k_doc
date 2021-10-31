# frozen_string_literal: true

module KDoc
  # CsvDoc is a DSL for modeling CSV data objects
  class CsvDoc < KDoc::Container
    include KLog::Logging

    # Create csv document
    #
    # @param [String|Symbol] name Name of the document
    # @param args[0] Type of the document, defaults to KDoc:: FakeOpinion.new.default_csv_type if not set
    # @param default: Default value (using named params), as above
    def initialize(key = nil, **opts, &block)
      super(**{ key: key }.merge(opts))

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

    def settings(key = nil, **opts, &block)
      opts ||= {}

      opts = {}.merge(@opts) # Data opts
               .merge(opts)  # Settings opts
               .merge(parent: self)

      settings_instance(@data, key, **opts, &block)
      # settings.run_decorators(opts)
    end

    def data
      @data ||= opts[:data] || opts[:default_data] || []
    end

    def csv_file
      return @csv_file if defined? @csv_file

      @csv_file = opts[:csv_file]
      @loaded   = false
    end

    private

    def initialize_attributes(**opts)
      @data     = opts[:data] || opts[:default_data] || []
      @csv_file = opts[:csv_file]
      @loaded   = false
    end

    def loaded?
      @loaded
    end

    def slice_option(key)
      return nil unless @opts.key?(key)

      result = @opts[key]
      @opts.delete(key)
      result
    end
  end
end
