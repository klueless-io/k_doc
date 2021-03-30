# frozen_string_literal: true

require 'json'

module KDoc
  # This is called fake opinion because I have not figured out
  # how I want to investigate this
  class FakeOpinion
    attr_accessor :default_document_type
    attr_accessor :default_settings_key
    attr_accessor :default_table_key

    def initialize
      # @default_document_type = :entity
      @default_settings_key = :settings
      @default_table_key = :table

      # @document_class = KDsl::Model::Document
      # @table_class = KDsl::Model::Table
      # @settings_class = KDsl::Model::Settings
      # @active_project = nil

      # @decorators = default_decorators
    end
  end
end
