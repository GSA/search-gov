# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching = true
config.action_view.cache_template_loading = true

config.logger = Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log")
config.logger.level = Logger::INFO

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
#config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
# Sent in emails to users
APP_URL = "search.usa.gov"

# protocol for login and logout url
SSL_PROTOCOL = "https"

# Enable threaded mode
# config.threadsafe!

# reCAPTCHA keys
RECAPTCHA_PUBLIC_KEY  = '***REMOVED***'
RECAPTCHA_PRIVATE_KEY = '***REMOVED***'

MONTHLY_REPORT_RECIPIENTS = ['amy.farrajfeijoo@gsa.gov', 'erik@searchsi.com', 'greg@shelrick.com', 'jayvirdy@gmail.com', 'GSA@insomniacdesign.com', 'marina.tuttle@gsa.gov']

config.gem "sauce", :version => '= 0.17.7'
config.gem "parallel", :version => '= 0.5.2'

config.after_initialize do
  MultiDb::ConnectionProxy.setup!
end