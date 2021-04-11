# frozen_string_literal: true

class AlterStructureSettingsDecorator < KDoc::Decorators::SettingsDecorator
  def update_settings(_target, settings)
    return unless settings.key?('full_name')

    settings['funny_name'] = settings['full_name'].downcase
    settings.delete('full_name')
  end
end
