# frozen_string_literal: true

sidekiq = Rails.application.config_for(:sidekiq)

Sidekiq.configure_server do |config|
  config.redis = { url: sidekiq['url'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: sidekiq['url'] }
end
