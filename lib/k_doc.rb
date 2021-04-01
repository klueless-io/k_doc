# frozen_string_literal: true

require 'securerandom'

require 'logger'
require 'table_print'
require 'k_log'
require 'k_util'
require 'k_log/log_formatter'
require 'k_log/log_helper'
require 'k_log/log_util'

require 'k_doc/version'
require 'k_doc/logging'
require 'k_doc/document'
require 'k_doc/fake_opinion'
require 'k_doc/settings'
require 'k_doc/table'
require 'k_doc/util'

module KDoc
  # raise KDoc::Error, 'Sample message'
  class Error < StandardError; end

  class << self
    # Factory method to create a new document
    def doc(key = nil, **options, &block)
      doc = KDoc::Document.new(key, **options, &block)
      doc.execute_block
      doc
    end

    attr_accessor :opinion
    attr_accessor :util
    attr_accessor :log
  end

  KDoc.opinion = KDoc::FakeOpinion.new
  KDoc.util = KDoc::Util.new
end

puts "KDoc::Version: #{KDoc::VERSION}" if ENV['KLUE_DEBUG']&.to_s&.downcase == 'true'
