# frozen_string_literal: true

require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque-scheduler'
require 'resque/scheduler/server'
require 'resque/server'
require 'resque/job_timeout'

host = ENV['REDIS_HOST']
port = ENV['REDIS_PORT']

Resque.redis = "#{host}:#{port}"

Resque::Failure::Multiple.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::Multiple

Resque::Plugins::JobTimeout.timeout = 1.hour
