require File.expand_path('../boot', __FILE__)

require 'rails/all'

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module UsasearchRails3
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/extras #{Rails.root}/lib)

    config.middleware.use "DowncaseRouteMiddleware"
    #    config.middleware.use ::Rack::PerftoolsProfiler

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running, except during DB migrations.
    unless File.basename($0) == "rake" && ARGV.include?("db:migrate")
      config.active_record.observers = :sayt_filter_observer, :misspelling_observer, :indexed_document_observer,
        :sitemap_observer, :site_domain_observer, :affiliate_observer, :navigable_observer
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end

# This has to be up here for some reason; otherwise, tests fail.
SUPPORTED_LOCALES = %w{en es}
SUPPORTED_LOCALE_WITH_NAMES = {'en' => 'English', 'es' => 'Spanish'}
SUPPORTED_LOCALE_OPTIONS = SUPPORTED_LOCALES.collect { |locale| [SUPPORTED_LOCALE_WITH_NAMES[locale], locale] }
SUPPORTED_VERTICALS = %w{web image recall}
BLOG_URL = 'http://usasearch.howto.gov'
TOS_URL = 'http://usasearch.howto.gov/tos'

require 'resque/plugins/priority'
