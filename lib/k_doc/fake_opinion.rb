# frozen_string_literal: true

require 'json'

module KDoc
  # This is called fake opinion because I have not figured out
  # how I want to implement this
  # Need to look at the configuration patterns, this is really a configuration
  class FakeOpinion
    attr_accessor :default_model_type
    attr_accessor :default_csv_type
    attr_accessor :default_json_type
    attr_accessor :default_yaml_type
    attr_accessor :default_settings_key
    attr_accessor :default_table_key

    # attr_accessor :document_class
    attr_accessor :settings_class
    attr_accessor :table_class

    def initialize
      @default_model_type = :entity
      @default_csv_type = :csv
      @default_json_type = :json
      @default_yaml_type = :yaml
      @default_settings_key = :settings
      @default_table_key = :table

      # @document_class = KDoc::Document
      @table_class = KDoc::Table
      @settings_class = KDoc::Settings
    end
  end
end
