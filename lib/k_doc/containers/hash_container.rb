# frozen_string_literal: true

module KDoc
  # A hash backed container acts as a base data object for any data can store hash data and  that requires tagging
  # such as unique key, type and namespace.
  class HashContainer < KDoc::Container
    def default_data_value
      {}
    end
  end
end
