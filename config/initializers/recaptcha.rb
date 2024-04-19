Recaptcha.configure do |config|
  return unless ENV['RECAPTCHA_SECRET_KEY'] || Rails.application.secrets.recaptcha

  config.secret_key = ENV['RECAPTCHA_SECRET_KEY'] || Rails.application.secrets.recaptcha[:secret_key]
  config.site_key   = ENV['RECAPTCHA_SITE_KEY']   || Rails.application.secrets.recaptcha[:site_key]
end
