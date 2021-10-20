require_relative 'boot'

require 'rails/all'
require './lib/middlewares/reject_invalid_request_uri.rb'
require './lib/middlewares/downcase_route.rb'
require './lib/middlewares/adjust_client_ip.rb'
require './lib/middlewares/filtered_jsonp.rb'


GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
GC::Profiler.enable

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Usasearch
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Introduced during upgrade to zeitwerk (SRCH-2503).  Ideally, we
    # wouldn't set any autoload paths explicitly. However, we have a
    # good deal of existing code that doesn't conform to zeitwerk's
    # naming conventions, so here's the necessary hackery to live with
    # that.
    #
    # We should try to reduce this list by changing existing code to
    # conform to the proper naming conventions.
    #
    # We should definitely *not* introduce any new code that needs an
    # entry here; conform to the proper naming convention(s) instead.
    #
    # See https://github.com/fxn/zeitwerk#file-structure
    #
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir[config.root.join('lib').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'active_job', 'uniqueness', 'strategies').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'callbacks').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'extensions').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'importers').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'middlewares').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'parsers').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'renderers').to_s]

    config.autoload_paths += Dir[config.root.join('app', 'models', 'custom_index_queries').to_s]
    config.autoload_paths += Dir[config.root.join('app', 'models', 'elastic_data').to_s]
    config.autoload_paths += Dir[config.root.join('app', 'models', 'logstash_queries').to_s]

    config.middleware.use RejectInvalidRequestUri
    config.middleware.use DowncaseRoute
    config.middleware.use AdjustClientIp
    config.middleware.use FilteredJSONP

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

    config.active_record.schema_format = :ruby

    config.i18n.enforce_available_locales = false

    config.ssl_options[:redirect] =
      { exclude: ->(request) { request.path == '/healthcheck' } }

    config.active_job.queue_adapter = :resque

    ### Rails 5.0 config flags
    ### SRCH-1058: The flags below should be flipped one by one to the new default.

    # Enable per-form CSRF tokens. Versions before Rails 5.0 had false.
    config.action_controller.per_form_csrf_tokens = false

    # Enable origin-checking CSRF mitigation.  Versions before Rails 5.0 had false.
    config.action_controller.forgery_protection_origin_check = false

    # Require `belongs_to` associations by default. Versions before Rails 5.0 had false.
    config.active_record.belongs_to_required_by_default = false

    # Make Ruby 2.4+ preserve the timezone of the receiver when calling `to_time`.
    # Versions before Rails 5.0 had false.
    ActiveSupport.to_time_preserves_timezone = false

    ### End Rails 5.0 config flags
  end
end


SEARCH_ENGINES = %w(BingV6 BingV7 Google SearchGov).freeze
DEFAULT_USER_AGENT = Rails.application.secrets.organization[:default_user_agent].freeze

require 'resque/plugins/priority'
require 'csv'
