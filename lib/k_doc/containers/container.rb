# frozen_string_literal: true

module KDoc
  # A container acts a base data object for any data that requires tagging
  # such as unique key, type and namespace.
  class Container
    include KLog::Logging
    include KDoc::Taggable
    include KDoc::Datum
    include KDoc::BlockProcessor

    attr_reader :opts

    # extend Forwardable

    # def_delegators :command, :run

    def initialize(**opts, &block)
      @opts = opts

      initialize_tag(opts)
      initialize_data(opts)
      initialize_block(opts, &block)

      guard("Incompatible data type - #{default_data_value.class} is incompatible with #{data.class}") unless data.is_a?(default_data_value.class)
    end

    def default_container_type
      :container
    end

    def default_data_value
      {}
    end

    def debug
      debug_container
      debug_errors
    end

    def guard(message)
      errors << message
    end

    def errors
      @errors ||= []
    end

    def valid?
      @errors.length.zero?
    end

    private

    def debug_errors
      log.block(errors, title: 'errors') unless valid?
    end
  end
end
