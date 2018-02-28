require 'resque/failure/airbrake'

config = Rails.application.secrets.system_redis
Resque.redis = [config['host'], config['port']].join(':')
