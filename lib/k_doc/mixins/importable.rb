# frozen_string_literal: true

module KDoc
  # Alow documents to import data from other sources (usually other documents)

  module Importable
    include KLog::Logging

    attr_reader :importer
    attr_reader :imports

    # Imports are provided via an options hash, these imports are remove from the hash as they are read
    #
    # Any container can import data from an existing container via the import options
    # rubocop:disable Style/OpenStructUse
    def initialize_import(opts)
      # log.error 'initialize_import'
      @importer = opts.delete(:importer)
      @imports = OpenStruct.new
    end
    # rubocop:enable Style/OpenStructUse

    def call_importer
      return unless importer

      importer.call(self)
    end

    # def import(tag)
    #   KManager.find_document(tag)
    # end

    # def import_data(tag, as: :document)
    #   doc = KManager.find_document(tag)

    #   return nil unless doc&.data

    #   # log.error 'about to import'
    #   doc.debug(include_header: true)

    #   return KUtil.data.to_open_struct(doc.data) if %i[open_struct ostruct].include?(as)

    #   doc.data
    # end

    protected

    def debug_importable
      # log.kv 'class type' , self.class.name   , debug_pad_size
    end
  end
end
