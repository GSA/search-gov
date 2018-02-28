Rails.application.config.session_store :redis_store,
  expires_in: 7200,
  secure: Rails.application.config.ssl_options[:secure_cookies],
  servers: Rails.application.secrets.session_redis.reverse_merge({
    db: 2,
    key_prefix: 'usasearch:session'
  })
