REDIS_HOST = ENV['REDIS_HOST'] || Rails.application.secrets.system_redis[:host]
REDIS_PORT = ENV['REDIS_PORT'] || Rails.application.secrets.system_redis[:port]
