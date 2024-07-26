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
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

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

    config.active_job.queue_adapter = :resque
    config.active_storage.queues.analysis = :searchgov
    config.active_storage.queues.purge = :searchgov

    # Require `belongs_to` associations by default. Versions before
    # Rails 5.0 had false.
    config.active_record.belongs_to_required_by_default = false

    config.react.camelize_props = true
  end
end
