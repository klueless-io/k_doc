# frozen_string_literal: true

module KDoc
  # Model is a DSL for modeling general purpose data objects
  #
  # A model can have
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

    def initialize(key = nil, **opts, &block)
      super(**{ key: key }.merge(opts), &block)
    end

    # Need to look at Director as an alternative to this technique
    def settings(key = nil, **setting_opts, &block)
      if block.nil?
        log.warn 'You cannot call settings without a block. Did you mean to call data[:settings] or odata.settings?'
        return
      end

      setting_opts = {}.merge(opts)         # Container options
                       .merge(setting_opts) # Settings setting_opts
                       .merge(parent: self)

      child = KDoc::Settings.new(self, data, key, **setting_opts, &block)

      add_child(child)
    end

    def table(key = :table, **opts, &block)
      if block.nil?
        log.warn 'You cannot call table without a block. Did you mean to call data[:table] or odata.table?'
        return
      end

      child = KDoc::Table.new(self, data, key, **opts, &block)

      add_child(child)
    end
    alias rows table

    # Sweet add-on would be builders
    # def builder(key, &block)
    #   # example
    #   KDoc::Builder::Shotstack.new(@data, key, &block)
    # end

    # Need to move this down to container
    # Need to use some sort of cache invalidation to know if the internal data has been altered
    def odata
      @odata ||= data_struct
    end

    def oraw
      @oraw ||= raw_data_struct
    end

    def data_struct
      KUtil.data.to_open_struct(data)
    end
    # alias d data_struct

    def raw_data_struct
      KUtil.data.to_open_struct(raw_data)
    end

    def default_container_type
      KDoc.opinion.default_model_type
    end

    def get_node_type(node_name)
      node_name = KUtil.data.clean_symbol(node_name)
      node_data = data[node_name]

      raise KDoc::Error, "Node not found: #{node_name}" if node_data.nil?

      if node_data.is_a?(Array)
        puts 'why is this?'
        return nil
      end

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
      debug_taggable
      debug_block_processor
      debug_header_keys

      log.line
    end

    def debug_header_keys
      opts&.keys&.reject { |k| k == :namespace }&.each do |key|
        log.kv key, opts[key]
      end
    end
  end
end
