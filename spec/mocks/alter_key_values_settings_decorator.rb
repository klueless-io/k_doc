# frozen_string_literal: true

# Example decorator for updating key/values on a Settings object
class AlterKeyValuesSettingsDecorator < KDoc::Decorators::SettingsDecorator
  def update_settings(_target, settings)
    settings.update(settings) do |key, value|
      case key.to_s
      when 'first_name'
        value.gsub('David', 'Dave')
      when 'last_name'
        value.gsub('Cruwys', 'was here')
      else
        value
      end
    end
    settings['full_name'] = "#{settings['first_name']} #{settings['last_name']}"
  end
end
