REDIS_HOST = ENV['REDIS_HOST'] || Rails.application.secrets.dig(:system_redis, :host)
REDIS_PORT = ENV['REDIS_PORT'] || Rails.application.secrets.dig(:system_redis, :port)
