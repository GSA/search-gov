# frozen_string_literal: true

sidekiq = Rails.application.config_for(:sidekiq)

Sidekiq.configure_server do |config|
  config.redis = { host: sidekiq['host'], port: sidekiq['port'] }
end

Sidekiq.configure_client do |config|
  config.redis = { host: sidekiq['host'], port: sidekiq['port'] }
end
