Rails.application.config.session_store :redis_store,
  expires_in: 7200,
  secure: Rails.application.config.ssl_options[:secure_cookies],
  servers: {
    host: ENV['REDIS_HOST'] || Rails.application.secrets.dig(:session_redis, :host),
    port: ENV['REDIS_PORT'] || Rails.application.secrets.dig(:session_redis, :port),
    db: 2,
    key_prefix: 'usasearch:session'
  }
