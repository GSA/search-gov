# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec'
require 'rspec/rails'
require 'remarkable'
require 'remarkable_activerecord'
require "email_spec"
require "authlogic/test_case"
require 'webrat'
require 'sunspot/rails/spec_helper'
require 'shoulda/integrations/rspec2'

include Authlogic::TestCase

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# figure out where we are being loaded from to ensure it's only done once
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise "foo"
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require "spec/spec_helper"

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  REDIS_PID = "#{Rails.root}/tmp/pids/redis-test.pid"
  REDIS_CACHE_PATH = "#{Rails.root}/tmp/cache/"

  config.before(:suite) do
    redis_options = {
      "daemonize" => 'yes',
      "pidfile" => REDIS_PID,
      "port" => 6380,
      "timeout" => 300,
      "save 900" => 1,
      "save 300" => 1,
      "save 60" => 10000,
      "dbfilename" => "dump.rdb",
      "dir" => REDIS_CACHE_PATH,
      "loglevel" => "debug",
      "logfile" => "stdout",
      "databases" => 16
    }.map { |k, v| "#{k} #{v}" }.join("\n")
    `echo '#{redis_options}' | redis-server -`
  end

  config.before(:each) do
    Redis.new(:host => REDIS_HOST, :port => REDIS_PORT).flushall
  end

  config.after(:suite) do
    %x{
      cat #{REDIS_PID} | xargs kill -9
      rm -f #{REDIS_CACHE_PATH}dump.rdb
    }
  end

end

Webrat.configure do |config|
  config.mode = :rails
end