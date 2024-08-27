Recaptcha.configure do |config|
  return unless ENV['RECAPTCHA_SECRET_KEY']

  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
  config.site_key   = ENV['RECAPTCHA_SITE_KEY']
end
