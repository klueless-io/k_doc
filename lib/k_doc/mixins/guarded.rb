# frozen_string_literal: true

module KDoc
  # Guarded provides parameter waring and guarding
  #
  # TODO: this could be moved into KType or KGuard
  module Guarded
    Guard = Struct.new(:type, :message)

    def guard(message)
      errors << Guard.new(:guard, message)
    end

    def warn(message)
      errors << Guard.new(:warning, message)
    end
    alias warning warn

    def errors
      @errors ||= []
    end

    def error_messages
      errors.map(&:message)
    end

    def error_hash
      errors.map(&:to_h)
    end

    # TODO: Add these predicates
    # def errors?
    # def warnings?

    def valid?
      errors.length.zero?
    end

    def log_any_messages
      errors.each do |error|
        log.warn error.message if error.type == :warning
        log.error error.message if error.type == :guard
      end
    end
  end
end
