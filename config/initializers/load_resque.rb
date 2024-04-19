# frozen_string_literal: true

require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque-scheduler'
require 'resque/scheduler/server'
require 'resque/server'
require 'resque/job_timeout'

host = ENV['REDIS_HOST'] || Rails.application.secrets.system_redis[:host]
port = ENV['REDIS_PORT'] || Rails.application.secrets.system_redis[:port]

Resque.redis = "#{host}:#{port}"

Resque::Failure::Multiple.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::Multiple

Resque::Plugins::JobTimeout.timeout = 1.hour
