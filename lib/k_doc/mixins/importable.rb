# frozen_string_literal: true

module KDoc
  # Alow documents to import data from other sources (usually other documents)

  module Importable
    include KLog::Logging

    # Proc/Handler to be called when importing data
    attr_reader :on_import

    # OpenStruct to be populated with data from import
    attr_reader :imports

    def initialize_import(opts)
      # log.error 'initialize_import'
      @on_import = opts.delete(:on_import)
      @imports = OpenStruct.new
    end

    def run_on_import
      return unless on_import

      instance_eval(&on_import)
    end
  end
end
