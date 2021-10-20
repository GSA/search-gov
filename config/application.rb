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
    config.autoloader = :classic # To be removed by SRCH-2503

    # Rails 4 way of “eager_load with autoload fallback. Note need to revisit better
    # solution. See https://collectiveidea.com/blog/archives/2016/07/22/solutions-to-potential-upgrade-problems-in-rails-5
    config.enable_dependency_loading = true # To be removed by SRCH-2503

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir[config.root.join('lib', '**/').to_s]
    config.autoload_paths += Dir[config.root.join('app/models', '**/').to_s]

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

    config.ssl_options[:redirect] =
      { exclude: ->(request) { request.path == '/healthcheck' } }

    config.active_job.queue_adapter = :resque

    # Require `belongs_to` associations by default. Versions before
    # Rails 5.0 had false.
    config.active_record.belongs_to_required_by_default = false
  end
end

require 'resque/plugins/priority'
require 'csv'
