require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque-timeout'

config = Rails.application.secrets.system_redis
Resque.redis = [config[:host], config[:port]].join(':')

Resque::Failure::Multiple.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::Multiple

Resque::Plugins::Timeout.timeout = 1.hour
