# frozen_string_literal: true

require 'json'

module KDoc
  # This is called fake opinion because I have not figured out
  # how I want to implement this
  class FakeOpinion
    attr_accessor :default_document_type
    attr_accessor :default_settings_key
    attr_accessor :default_table_key

    # attr_accessor :document_class
    attr_accessor :settings_class
    attr_accessor :table_class

    def initialize
      @default_document_type = :entity
      @default_settings_key = :settings
      @default_table_key = :table

      # @document_class = KDoc::Document
      @table_class = KDoc::Table
      @settings_class = KDoc::Settings
    end
  end
end
