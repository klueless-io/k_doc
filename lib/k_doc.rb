# frozen_string_literal: true

require 'securerandom'

require 'table_print'
require 'forwardable'
require 'k_log'
require 'k_type'
require 'k_util'
require 'k_decor'

require 'k_doc/version'
require 'k_doc/mixins/taggable'
require 'k_doc/mixins/datum'
require 'k_doc/mixins/block_processor'
require 'k_doc/mixins/composable_components'
require 'k_doc/containers/container'
require 'k_doc/containers/array_container'
require 'k_doc/containers/hash_container'
# require 'k_doc/data'
require 'k_doc/csv_doc'
require 'k_doc/json_doc'
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
    def model(key = nil, **options, &block)
      model = KDoc::Model.new(key, **options, &block)
      model.execute_block
      model
    end

    # These need to be registerable
    def document(key = nil, **options, &block)
      model(key, **{ type: :document }.merge(**options), &block)
    end

    def bootstrap(key = nil, **options, &block)
      model(key, **{ type: :bootstrap }.merge(**options), &block)
    end

    def app_settings(key = nil, **options, &block)
      model(key, **{ type: :app_settings }.merge(**options), &block)
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
