# frozen_string_literal: true

require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque-scheduler'
require 'resque/scheduler/server'
require 'resque/server'
require 'resque/job_timeout'

Resque.redis = ENV.fetch('REDIS_SYSTEM_URL')

Resque::Failure::Multiple.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::Multiple

Resque::Plugins::JobTimeout.timeout = 1.hour
