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
    include KDoc::Importable

    attr_reader :opts

    # TODO: Owner/Owned need to be in a module and tested
    attr_accessor :owner

    def owned?
      @owner != nil
    end

    def initialize(**opts, &block)
      @opts = opts

      initialize_tag(opts)
      initialize_data(opts)
      initialize_import(opts) if respond_to?(:initialize_import)
      initialize_block(opts, &block)
    end

    def default_container_type
      :container
    end

    def default_data_type
      @default_data_type ||= Hash
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
