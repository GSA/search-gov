require_relative "boot"

require "rails/all"
require './lib/middlewares/reject_invalid_request_uri.rb'
require './lib/middlewares/downcase_route.rb'
require './lib/middlewares/adjust_client_ip.rb'
require './lib/middlewares/filtered_jsonp.rb'
require 'resque/plugins/priority'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Usasearch
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #
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

    # Require `belongs_to` associations by default. Versions before
    # Rails 5.0 had false.
    config.active_record.belongs_to_required_by_default = false

    # Temporary workaround for:
    # https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    # A permanent solution will be implemented in https://cm-jira.usa.gov/browse/SRCH-3206
    config.active_record.use_yaml_unsafe_load = true
  end
end
