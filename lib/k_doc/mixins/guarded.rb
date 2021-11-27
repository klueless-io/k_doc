# frozen_string_literal: true

module KDoc
  # Guarded provides parameter waring and guarding
  #
  # TODO: this could be moved into KType or KGuard
  module Guarded
    def guard(message)
      errors << OpenStruct.new(type: :guard, message: message)
    end

    def warn(message)
      errors << OpenStruct.new(type: :warning, message: message)
    end
    alias warning warn

    def errors
      @errors ||= []
    end

    def error_messages
      @errors.map(&:message)
    end

    def valid?
      @errors.length.zero?
    end
  end
end
