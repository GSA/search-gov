# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Sent in emails to users
APP_URL = "localhost:3000"

# protocol for login and logout url
SSL_PROTOCOL = "http"

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

config.gem "rspec",            :lib => 'spec', :version => ['>= 1.3.0', '< 2.0.0']
config.gem "rspec-rails",      :lib => 'spec/rails', :version => ['>= 1.3.2', '< 2.0.0']
config.gem "remarkable_rails", :lib => false, :version => '>= 3.1.10'
config.gem "webrat",           :lib => false
config.gem "cucumber",         :lib => false, :version => '>= 0.10.0'
config.gem "cucumber-rails",   :lib => false, :version => '>= 0.3.2'
config.gem "rcov",             :lib => false
config.gem 'email_spec',       :lib => 'email_spec', :version => '=0.6.5'
config.gem "resque_spec",      :version => '~> 0.2.0'

# reCAPTCHA keys
# reCAPTCHA is configured to automatically skip for test and cucumber environments but the code still refers to these values
RECAPTCHA_PUBLIC_KEY  = 'PUBLIC_KEY'
RECAPTCHA_PRIVATE_KEY = 'PRIVATE_KEY'

MONTHLY_REPORT_RECIPIENTS = ['test@example.com', 'test2@example.com']
