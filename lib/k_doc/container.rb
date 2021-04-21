# frozen_string_literal: true

module KDoc
  # A container acts a base data object for any data requires tagging such as
  # unique key, type and namespace.
  class Container
    # include KLog::Logging

    attr_reader :key
    attr_reader :type
    attr_reader :namespace
    attr_reader :project_key
    attr_reader :error

    # Create container for storing data/documents.
    #
    # Any container can be uniquely identified via it's
    # key, type, namespace and project_key attributes
    #
    # @param [String|Symbol] name Name of the container
    # @param [String|Symbol] type Type of the container, defaults to KDoc:: FakeOpinion.new.default_document_type if not set
    # @param [String|Symbol] namespace Namespace that the container belongs to
    # @param [String|Symbol] project_key Project that the container belongs to
    def initialize(key: nil, type: nil, namespace: nil, project_key: nil)
      @key = key || SecureRandom.alphanumeric(8)
      @type = type || KDoc.opinion.default_document_type
      @namespace = namespace || ''
      @project_key = project_key || ''
    end

    def unique_key
      @unique_key ||= KDoc.util.build_unique_key(key, type, namespace, project_key)
    end

    def debug_header
      log.kv 'key', key
      log.kv 'type', type
      log.kv 'namespace', namespace
      log.kv 'project_key', namespace
      log.kv 'error', error
    end
  end
end
