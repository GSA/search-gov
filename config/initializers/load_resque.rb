require 'resque/failure/airbrake'

Airbrake.configure do |config|
  config.api_key = '***REMOVED***'
  config.secure = false
end

config = YAML::load(ERB.new(File.read("#{Rails.root}/config/redis.yml")).result)[Rails.env]
Resque.redis = [config['host'], config['port']].join(':')
REDIS_HOST = config['host']
REDIS_PORT = config['port']
