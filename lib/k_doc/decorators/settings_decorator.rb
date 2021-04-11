# frozen_string_literal: true

# This could move into KDecor
module KDoc
  module Decorators
    class SettingsDecorator < BaseDecorator
      def initialize
        super(KDoc::Settings)

        self.available_behaviors = [:update_settings]
        self.implemented_behaviors = [:update_settings]
      end

      def update(target, behavior)
        update_settings(target, target.internal_data) if behavior == :all || behavior == :update_settings

        target
      end

      # What responsibility will this SettingsDecorator take on?
      def update_settings(_target, _settings)
        log.warn('Override this method in your descendant implementation')
      end
    end
  end
end
