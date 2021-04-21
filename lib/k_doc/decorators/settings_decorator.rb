# frozen_string_literal: true

# This could move into KDecor
module KDoc
  module Decorators
    class SettingsDecorator < KDecor::BaseDecorator
      def initialize
        super(KDoc::Settings)
      end

      # def update(target, behaviour)
      #   update_settings(target, target.internal_data) if %i[all default].include?(behaviour)

      #   target
      # end

      # # What responsibility will this SettingsDecorator take on?
      # def update(target, **_opts)
      #   def update_settings(_target, _settings)
      #   log.warn('Override this method in your descendant implementation')
      # end
    end
  end
end
