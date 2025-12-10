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
    config.autoload_lib(ignore: %w(assets tasks middlewares i18n_jsx_scanners))

    # Legacy directories with top-level constants (not following Zeitwerk naming conventions).
    # Added to both autoload_paths and eager_load_paths to enable top-level constant access
    # and ensure zeitwerk:check validates them.
    legacy_lib_paths = %w[
      lib/active_job/uniqueness/strategies
      lib/callbacks
      lib/extensions
      lib/importers
      lib/parsers
      lib/renderers
    ].map { |path| config.root.join(path).to_s }

    legacy_app_paths = %w[
      app/jobs/legacy
      app/models/custom_index_queries
      app/models/elastic_data
      app/models/logstash_queries
    ].map { |path| config.root.join(path).to_s }

    config.autoload_paths += legacy_lib_paths + legacy_app_paths
    config.eager_load_paths += legacy_lib_paths + legacy_app_paths

    config.middleware.use RejectInvalidRequestUri
    config.middleware.use DowncaseRoute
    config.middleware.use AdjustClientIp
    config.middleware.use FilteredJSONP

    config.semantic_logger.application = ENV.fetch('APP_NAME', 'searchgov-web')

    # Activate observers that should always be running, except during DB migrations.
    unless File.basename($0) == "rake" && ARGV.include?("db:migrate")
      config.active_record.observers = :sayt_filter_observer, :misspelling_observer, :indexed_document_observer,
        :affiliate_observer, :navigable_observer, :searchable_observer,
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

    # Temporary workaround for:
    # https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    # A permanent solution will be implemented in https://cm-jira.usa.gov/browse/SRCH-3206
    config.active_record.use_yaml_unsafe_load = true
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
