Rails.application.config.session_store :redis_store,
  expires_in: 7200,
  secure: Rails.application.config.ssl_options[:secure_cookies],
  key: '_usasearch_session',
  servers: {
    host: ENV['REDIS_SESSION_HOST'],
    port: ENV['REDIS_SESSION_PORT'],
    db: 2,
    key_prefix: 'usasearch:session'
  }
