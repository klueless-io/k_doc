# frozen_string_literal: true

class ModelPluralSettingsDecorator < KDoc::Decorators::SettingsDecorator
  def update_settings(_target, settings)
    return unless settings.key?('model') && (!settings.key?('model_plural') || settings['model_plural'].nil?)

    settings['model_plural'] = "#{settings['model']}s"
  end
end
