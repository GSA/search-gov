# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching = true
config.action_view.cache_template_loading = true

# See everything in the log (default is :info)
config.log_level = :warn
config.logger = Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log")

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
# Sent in emails to users
APP_URL = "search.usa.gov"

# Enable threaded mode
# config.threadsafe!

require 'memcache'
begin
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
# We're in smart spawning mode, so...
# Close duplicated memcached connections - they will open themselves
      Rails.cache.instance_variable_get(:@data).reset
    end
  end
# In case you're not running under Passenger (i.e. devmode with mongrel)
rescue NameError => error
end
