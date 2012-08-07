require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

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
require 'paperclip/matchers'
require 'rspec/autorun'

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
  config.include Paperclip::Shoulda::Matchers

  REDIS_PID = "#{Rails.root}/tmp/pids/redis-test.pid"
  REDIS_CACHE_PATH = "#{Rails.root}/tmp/cache/"

  config.before(:suite) do
    Dir.mkdir("#{Rails.root}/tmp/cache") unless File.directory?("#{Rails.root}/tmp/cache")
    Dir.mkdir("#{Rails.root}/tmp/pids") unless File.directory?("#{Rails.root}/tmp/pids")
    redis_options = {
      "daemonize" => 'yes',
      "pidfile" => REDIS_PID,
      "port" => 6380,
      "timeout" => 300,
      "dbfilename" => "dump.rdb",
      "dir" => REDIS_CACHE_PATH,
      "loglevel" => "debug",
      "logfile" => "stdout",
      "databases" => 16
    }.map { |k, v| "#{k} #{v}" }.join("\n")
    `echo '#{redis_options}' | redis-server -`

    EmailTemplate.load_default_templates
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

