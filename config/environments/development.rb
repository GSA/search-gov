UsasearchRails3::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :logger

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Switch for testing static assets in development
  test_static_assets = false

  if test_static_assets
    # Behave much like production (requiring assets to be
    # precompiled), but using the Rails static asset server
    # rather than an Apache/nginx reverse proxy.
    config.serve_static_assets = true
    config.assets.compress = true
    config.assets.css_compressor = :yui
    config.assets.js_compressor = :uglifier
    config.assets.compile = false
    config.assets.digest = true
    config.assets.precompile += %w( font-awesome-grunticon-rails.js )
    config.assets.precompile += Dir.entries("#{Rails.root}/app/assets/javascripts/").select { |e| e =~ /^(?!application\.js).+\.js$/ }
    config.assets.precompile += Dir.entries("#{Rails.root}/app/assets/stylesheets/").select { |e| e =~ /^(?!application\.css).+\.css$/ }
  else
    # Do not compress assets
    config.assets.compress = false
    # Expands the lines which load the assets
    config.assets.debug = true
  end
end

# Sent in emails to users
APP_URL = "localhost:3000"

# protocol for login and logout url
SSL_PROTOCOL = "http"

# reCAPTCHA keys
RECAPTCHA_PUBLIC_KEY  = '***REMOVED***'
RECAPTCHA_PRIVATE_KEY = '***REMOVED***'

ADDITIONAL_BING_PARAMS = { 'traffictype' => 'test' }

DEFAULT_CACHE_DURATION = 6.hours
AZURE_CACHE_DURATION = 1.day
BING_CACHE_DURATION = 1.day
GOOGLE_CACHE_DURATION = 5.minutes
