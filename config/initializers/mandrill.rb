require 'mandrill_adapter'

if smtp_settings = MandrillAdapter.new.smtp_settings
  Rails.application.config.action_mailer.smtp_settings = smtp_settings
end
