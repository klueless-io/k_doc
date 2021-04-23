# frozen_string_literal: true

module KDoc
  # Utility helper methods for KDoc
  class Util
    # Build a unique key so that resources of the same key do not conflict with
    # one another across projects, namespaces or types
    #
    # @param [String] param_name Param description
    def build_unique_key(key, type = nil, namespace = nil, project_key = nil)
      raise KDoc::Error, 'key is required when generating unique key' if key.nil? || key.empty?

      type ||= KDoc.opinion.default_document_type

      keys = [project_key, namespace, key, type].reject { |k| k.nil? || k == '' }.map { |k| k.to_s.gsub('_', '-') }

      keys.join('-')
    end
  end
end
