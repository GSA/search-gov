Recaptcha.configure do |config|
  return unless Rails.application.secrets.recaptcha

  config.secret_key = Rails.application.secrets.recaptcha[:secret_key]
  config.site_key   = Rails.application.secrets.recaptcha[:site_key]
end
