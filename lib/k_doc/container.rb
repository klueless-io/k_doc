# frozen_string_literal: true

module KDoc
  # A data acts a base data object for any data requires tagging such as
  # unique key, type and namespace.
  class Container
    # include KLog::Logging

    # Name of the document (required)
    #
    # Examples: user, account, country
    attr_reader :key

    # Type of data
    #
    # Examples by data type
    #   :csv, :yaml, :json, :xml
    #
    # Examples by shape of the data in a DSL
    #   :entity, :microapp, blueprint
    attr_reader :type

    attr_writer :data

    # Move this up to k_manager
    # attr_reader :namespace
    # attr_reader :project_key
    attr_reader :error

    # Create container for storing data/documents.
    #
    # Any container can be uniquely identified via it's
    # key, type, namespace and project_key attributes
    #
    # @param [Hash] **opts The options
    # @option opts [String|Symbol] name Name of the container
    # @option opts [String|Symbol] type Type of the container, defaults to KDoc:: FakeOpinion.new.default_model_type if not set
    # @option opts [String|Symbol] namespace Namespace that the container belongs to
    # @option opts [String|Symbol] project_key Project that the container belongs to
    def initialize(**opts)
      @key = opts[:key] || SecureRandom.alphanumeric(4)
      @type = opts[:type] || ''
      @data = opts[:data] || {}
    end

    def debug_header
      log.kv 'key', key
      log.kv 'type', type
    end

    def data
      @data.clone
    end
  end
end
