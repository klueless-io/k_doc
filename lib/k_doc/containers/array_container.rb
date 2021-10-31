# frozen_string_literal: true

module KDoc
  # A array backed container acts as a base data object for any data can store array data and  that requires tagging
  # such as unique key, type and namespace.
  class ArrayContainer < KDoc::Container
    def default_data_value
      []
    end
  end
end
