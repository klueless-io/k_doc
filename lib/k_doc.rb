# frozen_string_literal: true

require 'securerandom'

require 'table_print'
require 'k_log'
require 'k_type'
require 'k_util'
require 'k_decor'

require 'k_doc/version'
require 'k_doc/container'
# require 'k_doc/data'
require 'k_doc/model'
require 'k_doc/fake_opinion'
require 'k_doc/settings'
require 'k_doc/table'

require 'k_doc/decorators/settings_decorator'
require 'k_doc/decorators/table_decorator'

module KDoc
  # raise KDoc::Error, 'Sample message'
  class Error < StandardError; end

  class << self
    # Is this needed
    # Factory method to create a new model
    def model(key = nil, **options, &block)
      model = KDoc::Model.new(key, **options, &block)
      model.execute_block
      model
    end

    attr_accessor :opinion
    attr_accessor :log
  end

  KDoc.opinion = KDoc::FakeOpinion.new
end

if ENV['KLUE_DEBUG']&.to_s&.downcase == 'true'
  namespace = 'KDoc::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('k_doc/version') }
  version   = KDoc::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
