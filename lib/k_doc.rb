# frozen_string_literal: true

require 'securerandom'

require 'table_print'
require 'k_log'
require 'k_type'
require 'k_util'

require 'k_doc/version'
require 'k_doc/data'
require 'k_doc/fake_opinion'
require 'k_doc/settings'
require 'k_doc/table'
require 'k_doc/util'

require 'k_doc/decorators/base_decorator'
require 'k_doc/decorators/settings_decorator'
require 'k_doc/decorators/table_decorator'

module KDoc
  # raise KDoc::Error, 'Sample message'
  class Error < StandardError; end

  class << self
    # Factory method to create a new data
    def data(key = nil, **options, &block)
      data = KDoc::Data.new(key, **options, &block)
      data.execute_block
      data
    end

    attr_accessor :opinion
    attr_accessor :util
    attr_accessor :log
  end

  KDoc.opinion = KDoc::FakeOpinion.new
  KDoc.util = KDoc::Util.new
end

if ENV['KLUE_DEBUG']&.to_s&.downcase == 'true'
  namespace = 'KDoc::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('k_doc/version') }
  version   = KDoc::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
