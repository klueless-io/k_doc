# frozen_string_literal: true

module KDoc
  # A data acts a base data object for any data requires tagging such as
  # unique key, type and namespace.
  class Container
    # include KLog::Logging

    # Seems like there is way too much data here
    # Firstly it should probably be in an interface
    # Secondly some of this (namespace, project_key, error) belongs in k_manager
    # So container would be better off just being key, type, data
    attr_reader :key

    # NOTE: This should not be using an opinion in this project
    attr_reader :type

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
    # @option opts [String|Symbol] type Type of the container, defaults to KDoc:: FakeOpinion.new.default_document_type if not set
    # @option opts [String|Symbol] namespace Namespace that the container belongs to
    # @option opts [String|Symbol] project_key Project that the container belongs to
    def initialize(**opts)
      @key = opts[:key] || SecureRandom.alphanumeric(4)
      @type = opts[:type] || '' # KDoc.opinion.default_document_type
      # @namespace = opts[:namespace] || ''
      # @project_key = opts[:project_key] || ''

      # Old name is default_data, wonder if I still need that idea?
      # Most documents live within a hash, some tabular documents such as CSV will use an []
      # @data       = slice_option(:default_data) || {}
      @data = opts[:data] || {}
    end

    # def unique_key
    #   @unique_key ||= KDoc.util.build_unique_key(key, type, namespace, project_key)
    # end

    def debug_header
      log.kv 'key', key
      log.kv 'type', type
      # log.kv 'namespace', namespace
      # log.kv 'project_key', namespace
      # log.kv 'error', error
    end

    attr_writer :data

    def data
      @data.clone
    end
  end
end
