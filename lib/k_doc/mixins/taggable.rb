# frozen_string_literal: true

module KDoc
  # A container acts a base data object for any data that requires tagging
  # such as unique key, type and namespace.
  module Taggable
    include KLog::Logging

    attr_reader :tag_options

    # Tags are provided via an options hash, these tags are remove from the hash as they are read
    #
    # Any container can be uniquely identified via it's key, type, namespace and project_key tags
    #
    # @param [Hash] opts The options
    # @option opts [String|Symbol] project Project Name
    # @option opts [String|Symbol|Array] namespace Namespace or array if namespace is deep nested
    # @option opts [String|Symbol] name Container Name
    # @option opts [String|Symbol] type Type of the container, uses default_container_type if not set
    def initialize_tag(opts)
      @tag_options = opts
      build_tag
    end

    def tag
      return @tag if defined? @tag
    end

    # Name of the document (required)
    #
    # Examples: user, account, country
    def key
      @key ||= @tag_options.delete(:key) || SecureRandom.alphanumeric(4)
    end

    # Type of data
    #
    # Examples by data type
    #   :csv, :yaml, :json, :xml
    #
    # Examples by shape of the data in a DSL
    #   :entity, :microapp, blueprint
    def type
      @type ||= @tag_options.delete(:type) || default_container_type
    end

    # TODO: rename to area (or area root namespace)
    # Project name
    #
    # Examples
    #   :app_name1, :app_name2, :library_name1
    def project
      @project ||= @tag_options.delete(:project) || ''
    end

    # Namespace(s) what namespace is this document under
    #
    # Example for single path
    #   :controllers, :models
    #
    # Example for deep path
    #   [:app, :controllers, :admin]
    def namespace
      return @namespace if defined? @namespace

      ns = @tag_options.delete(:namespace) || []
      @namespace = ns.is_a?(Array) ? ns : [ns]
    end

    # # Internal data object
    # def data
    #   @data ||= @tag_options.delete(:data) || @tag_options.delete(:default_data) || default_data_value
    #   # Settings and Table on Model needed access to @data for modification, I don't think this should be a clone
    #   # never return the original data object, but at the same time
    #   # do not re-clone it every time this accessor is called.
    #   # @clone_data ||= @data.clone
    # end

    # Implement in container
    # def default_container_type
    # :container
    # end

    # def default_data_value
    #   {}
    # end

    protected

    # rubocop:disable Metrics/AbcSize
    def debug_container
      log.kv 'tag'        , tag               , debug_pad_size
      log.kv 'project'    , project           , debug_pad_size unless project.nil? || project.empty?
      log.kv 'namespace'  , namespace         , debug_pad_size unless namespace.nil? || namespace.empty?
      log.kv 'key'        , key               , debug_pad_size
      log.kv 'type'       , type              , debug_pad_size
      log.kv 'class type' , self.class.name   , debug_pad_size
      # log.kv 'error'    , error     , debug_kv_pad_size
    end
    # rubocop:enable Metrics/AbcSize

    def debug_pad_size
      @debug_pad_size ||= @tag_options.delete(:debug_pad_size) || 20
    end

    private

    def build_tag
      values = []
      values << project if project
      values += namespace
      values << key
      values << type if type
      values -= [nil, '']
      @tag = values.join('_').to_sym
    end
  end
end
