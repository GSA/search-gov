require File.expand_path('../boot', __FILE__)

require 'rails/all'

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)
GC::Profiler.enable

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module UsasearchRails3
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

    config.paths.add File.join('app', 'api', 'search_consumer'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', 'search_consumer' '*')]

    config.middleware.insert_before 0, "Rack::Cors" do
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

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    config.generators do |g|
      g.test_framework :rspec
    end

    config.assets.enabled = true
    config.assets.version = '1.0'

    # Configure asset pipeline behaviors on a per-server basis. In a canonical
    # Rails world, we would simply place these settings in environment/*.rb.
    #
    # Unfortunately our architecture currently treats staging and prod both as
    # RAILS_ENV=production, which means that we need some other way to specify
    # settings that differ between staging and production. (In case you are
    # wondering, the rationale for this is the seemingly convincing argument
    # that "staging should be just like production", which it is...except, of
    # course, when it isn't. Thus this tap-dance. *Sigh*)
    #
    # Anyway, YAML files that contain server-specific settings seems to be the
    # method that we have chosen to work around this self-inflicted wound. Load
    # one such file here in order to set the asset_host if needed.

    ac_yml = "#{Rails.root}/config/asset_configuration.yml"

    if ::File.exists?(ac_yml)
      begin
        ac = YAML.load_file(ac_yml)[Rails.env]
        ac.each do |k,v|
          UsasearchRails3::Application.configure do
            config.action_controller.send(:"#{k}=", v)
          end
        end
      rescue Exception => e
        STDERR.puts "Unable to load asset configuration for environment #{Rails.env} in #{ac_yml}, skipping: #{e.message}"
      end
    end

    config.active_record.schema_format = :sql
    config.active_record.whitelist_attributes = false

    require 'mandrill_adapter'
    if smtp_settings = MandrillAdapter.new.smtp_settings
       config.action_mailer.smtp_settings = smtp_settings
    end

    config.i18n.enforce_available_locales = false

    config.ssl_options[:secure_cookies] = false
  end
end

BLOG_URL = 'https://search.digitalgov.gov'
TOS_URL = 'https://search.digitalgov.gov/tos'
USA_GOV_URL = 'https://www.usa.gov'
PAGE_NOT_FOUND_URL = 'https://www.usa.gov/page-not-found/'.freeze
SUPPORT_EMAIL_ADDRESS = 'search@support.digitalgov.gov'.freeze
DEFAULT_USER_AGENT = 'usasearch'.freeze
SEARCH_ENGINES = %w(BingV6 Google SearchGov).freeze

require 'resque/plugins/priority'
require 'csv'
