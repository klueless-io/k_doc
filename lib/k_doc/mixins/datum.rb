# frozen_string_literal: true

module KDoc
  # Data acts as a base data object containers
  module Datum
    include KDoc::Guarded

    attr_reader :data

    def initialize_data(opts)
      @data = opts.delete(:data) || opts.delete(:default_data) || default_data_value

      return if data.is_a?(default_data_value.class)

      warn("Incompatible data type - #{default_data_value.class} is incompatible with #{data.class}")
      @data = default_data_value
    end

    def default_data_value
      raise 'Implement default_data_value in container'
    end

    # Write data object
    #
    # @param [Object] value A compatible data object to be stored against .data property
    # @param [Symbol] data_action The data_action to take when setting data, defaults to :replace
    # @param [:replace] data_action :replace will replace the existing data instance with the incoming data value
    # @param [:append] data_action :append will keep existing data and then new value data over the top
    def set_data(value, data_action: :replace)
      return warn("Incompatible data type - #{default_data_value.class} is incompatible with #{value.class}") unless value.is_a?(default_data_value.class)

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
