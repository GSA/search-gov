require 'resque/failure/airbrake'

Airbrake.configure do |config|
  config.api_key = '***REMOVED***'
  config.secure = true
end

config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
Resque.redis = [config['host'], config['port']].join(':')
REDIS_HOST = config['host']
REDIS_PORT = config['port']
