# frozen_string_literal: true

module KDoc
  # Data acts as a base data object containers
  module Datum
    attr_reader :data

    def initialize_data(opts)
      @data = opts.delete(:data) || opts.delete(:default_data) || default_data_value
    end

    def default_data_value
      raise 'Implement default_data_value in container'
    end
  end
end
