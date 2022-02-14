# frozen_string_literal: true

module KDoc
  # A container acts a base data object for any data that requires tagging
  # such as unique key, type and namespace.
  class Container
    include KLog::Logging
    include KDoc::Guarded
    include KDoc::Taggable
    include KDoc::Datum
    include KDoc::BlockProcessor

    # OpenStruct to be populated with context data, this can be used inside the on_init
    attr_reader :context

    # Opts that are passed to the container. Some options will be removed when evaluated by different plugins (Taggable, BlockProcessor)
    attr_reader :opts

    # TODO: Owner/Owned need to be in a module and tested
    attr_accessor :owner

    def owned?
      @owner != nil
    end

    def initialize(**opts, &block)
      @context = OpenStruct.new
      @opts = opts

      initialize_tag(opts)
      initialize_data(opts)
      initialize_block(opts, &block)
    end

    def default_container_type
      :container
    end

    def default_data_type
      @default_data_type ||= Hash
    end

    def os(**opts)
      OpenStruct.new(opts)
    end

    def debug
      debug_taggable
      debug_block_processor
      debug_errors
    end

    private

    def debug_errors
      log.block(errors, title: 'errors') unless valid?
    end
  end
end
