# frozen_string_literal: true

module KDoc
  # Data acts as a base data object containers
  module Datum
    include KDoc::Guarded

    attr_reader :data

    def initialize_data(opts)
      @default_data_type = opts.delete(:default_data_type) if opts.key?(:default_data_type)
      @data = opts.delete(:data) || opts.delete(:default_data) || default_data_type.new

      warn("Incompatible data type - #{default_data_type} is incompatible with #{data.class} in constructor") unless data.is_a?(default_data_type)
    end

    def default_data_type
      raise 'Implement default_data_type in container' unless @default_data_type
    end

    # Write data object
    #
    # @param [Object] value A compatible data object to be stored against .data property
    # @param [Symbol] data_action The data_action to take when setting data, defaults to :replace
    # @param [:replace] data_action :replace will replace the existing data instance with the incoming data value
    # @param [:append] data_action :append will keep existing data and then new value data over the top
    def set_data(value, data_action: :replace)
      warn("Incompatible data type - #{default_data_type} is incompatible with #{value.class} in set data") unless value.is_a?(default_data_type)

      case data_action
      when :replace
        @data = value
      when :append
        @data.merge!(value) if @data.is_a?(Hash)
        @data += value if @data.is_a?(Array)
      else
        warn("Unknown data_action: #{data_action}")
      end
    end

    def clear_data
      @data.clear
    end
  end
end
