Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Switch for testing static assets in development
  test_static_assets = false

  if test_static_assets
    # Behave much like production (requiring assets to be precompiled), but
    # using the Rails static asset server rather than an Apache/nginx
    # reverse proxy. Also, don't compress the files because that makes them
    # hard to read.
    config.serve_static_files = true
    config.assets.compress = false
    config.assets.compile = false
    config.assets.digest = true
  else
    # Do not compress assets
    config.assets.compress = false
    # Expands the lines which load the assets
    config.assets.debug = true
  end
end

ADDITIONAL_BING_PARAMS = { 'traffictype' => 'test' }

DEFAULT_CACHE_DURATION = 6.hours
AZURE_CACHE_DURATION = 1.day
BING_CACHE_DURATION = 1.day
GOOGLE_CACHE_DURATION = 5.minutes
I14Y_CACHE_DURATION = 1.day
