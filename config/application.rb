require_relative "boot"

require "rails/all"
require './lib/middlewares/reject_invalid_request_uri'
require './lib/middlewares/downcase_route'
require './lib/middlewares/adjust_client_ip'
require './lib/middlewares/filtered_jsonp'
require 'resque/plugins/priority'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Usasearch
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    config.autoload_paths += Dir[config.root.join('lib', 'active_job', 'uniqueness', 'strategies').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'callbacks').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'extensions').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'importers').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'middlewares').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'parsers').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'renderers').to_s]
    config.autoload_paths += Dir[config.root.join('lib', 'i18n_jsx_scanners').to_s]

    # Our legacy, Resque-based jobs that should be refactored to inherit from ActiveJob
    config.autoload_paths += Dir[config.root.join('app', 'jobs', 'legacy').to_s]

    config.autoload_paths += Dir[config.root.join('app', 'models', 'custom_index_queries').to_s]
    config.autoload_paths += Dir[config.root.join('app', 'models', 'elastic_data').to_s]
    config.autoload_paths += Dir[config.root.join('app', 'models', 'logstash_queries').to_s]

    config.middleware.use RejectInvalidRequestUri
    config.middleware.use DowncaseRoute
    config.middleware.use AdjustClientIp
    config.middleware.use FilteredJSONP

    config.semantic_logger.application = ENV.fetch('APP_NAME', 'searchgov-web')

    # Activate observers that should always be running, except during DB migrations.
    unless File.basename($0) == "rake" && ARGV.include?("db:migrate")
      config.active_record.observers = :sayt_filter_observer, :misspelling_observer, :indexed_document_observer,
        :affiliate_observer, :navigable_observer, :searchable_observer, :rss_feed_url_observer,
        :i14y_drawer_observer, :routed_query_keyword_observer, :watcher_observer
    end

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found)
    config.i18n.fallbacks = true

    config.i18n.enforce_available_locales = false

    config.ssl_options[:redirect] =
      { exclude: ->(request) { request.path == '/healthcheck' } }

    config.active_job.queue_adapter = :resque
    config.active_storage.queues.analysis = :searchgov
    config.active_storage.queues.purge = :searchgov

    # Require `belongs_to` associations by default. Versions before
    # Rails 5.0 had false.
    config.active_record.belongs_to_required_by_default = false

    config.react.camelize_props = true
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_controller.allow_deprecated_parameters_hash_equality = false

    # Disable deprecated singular associations names.
    config.active_record.allow_deprecated_singular_associations_name = false

    config.active_record.raise_on_assign_to_attr_readonly = false
  end
end
