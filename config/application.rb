require File.expand_path('../boot', __FILE__)

require 'rails/all'

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
GC::Profiler.enable

Bundler.require(*Rails.groups)

module Usasearch
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir[config.root.join('lib', '**/').to_s]
    config.autoload_paths += Dir[config.root.join('app/models', '**/').to_s]

    config.middleware.use 'RejectInvalidRequestUri'
    config.middleware.use 'DowncaseRoute'
    config.middleware.use 'AdjustClientIp'
    config.middleware.use 'FilteredCORS'
    config.middleware.use 'FilteredJSONP'
    # config.middleware.use ::Rack::PerftoolsProfiler

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '/api/c/', :headers => :any, :methods => [:get, :put, :post, :options]
        resource '/assets/*', :headers => :any, :methods => [:get, :head, :options]
      end
    end

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running, except during DB migrations.
    unless File.basename($0) == "rake" && ARGV.include?("db:migrate")
      config.active_record.observers = :sayt_filter_observer, :misspelling_observer, :indexed_document_observer,
        :affiliate_observer, :navigable_observer, :searchable_observer, :rss_feed_url_observer,
        :i14y_drawer_observer, :routed_query_keyword_observer, :watcher_observer
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found)
    config.i18n.fallbacks = true

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    config.generators do |g|
      g.test_framework :rspec
    end

    config.assets.enabled = true
    config.assets.version = '1.0'

    config.active_record.schema_format = :sql

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.i18n.enforce_available_locales = false

    config.ssl_options[:secure_cookies] = false
    config.active_job.queue_adapter = :resque
  end
end

SEARCH_ENGINES = %w(BingV6 BingV7 Google SearchGov).freeze
DEFAULT_USER_AGENT = Rails.application.secrets.organization['default_user_agent'].freeze

require 'resque/plugins/priority'
require 'csv'
