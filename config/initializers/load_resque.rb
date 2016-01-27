require 'resque/failure/airbrake'

config = YAML::load(ERB.new(File.read("#{Rails.root}/config/redis.yml")).result)[Rails.env]
Resque.redis = [config['host'], config['port']].join(':')
REDIS_HOST = config['host']
REDIS_PORT = config['port']
