Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # enabled by default, but we don't care if the client might be lying about their IP address
  config.action_dispatch.ip_spoofing_check = false

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_files = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true
  config.ssl_options[:secure_cookies] = true

  # needs autoloading while running in production mode
  config.enable_dependency_loading = true
end

ADDITIONAL_BING_PARAMS = {}

DEFAULT_CACHE_DURATION = 6.hours
AZURE_CACHE_DURATION = 1.day
BING_CACHE_DURATION = 1.day
GOOGLE_CACHE_DURATION = 5.minutes
I14Y_CACHE_DURATION = 1.day
