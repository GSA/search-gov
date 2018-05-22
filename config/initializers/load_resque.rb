require 'airbrake/resque'
require 'resque/failure/multiple'
require 'resque/failure/redis'

config = Rails.application.secrets.system_redis
Resque.redis = [config['host'], config['port']].join(':')

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
Resque::Failure.backend = Resque::Failure::Multiple
