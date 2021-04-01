# frozen_string_literal: true

module KDoc
  # Utility helper methods for KDoc
  class Util
    def build_unique_key(key, type = nil, namespace = nil)
      raise KDoc::Error, 'key is required when generating unique key' if key.nil? || key.empty?

      type ||= KDoc.opinion.default_document_type

      namespace.nil? || namespace.empty? ? "#{key}_#{type}" : "#{namespace}_#{key}_#{type}"
    end
  end
end
