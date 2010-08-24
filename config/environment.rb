# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  # Specify gems that this application depends on and have them installed with rake gems:install
  config.gem "haml", :version => '2.2.3'
  config.gem "json", :version => '>= 1.4.3'
  config.gem 'mislav-will_paginate', :version => '~> 2.3.11', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem "chriseppstein-compass", :lib => 'compass', :source => 'http://gems.github.com', :version => '>= 0.8.9'
  config.gem "hpricot", :version => '>= 0.8.2'
  config.gem "calendar_date_select", :version => '>= 1.16.1'
  config.gem "bcrypt-ruby", :lib => "bcrypt", :version => '>= 2.1.1'
  config.gem "authlogic", :version => '>= 2.1.5'
  config.gem 'schoefmax-multi_db', :lib => 'multi_db', :source => 'http://gems.github.com'
  config.gem 'sunspot_rails', :lib => 'sunspot/rails', :version => '1.1.0'
  config.gem 'hoptoad_notifier', :version => '2.3.4'
  config.gem 'fastercsv'
  config.gem 'calais', :version => '>= 0.0.11'
  config.gem "aws-s3", :lib => "aws/s3", :version => '0.6.2'

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
end

APP_EMAIL_ADDRESS = "***REMOVED***"

AWS_ACCESS_KEY_ID = "AKIAIVNWMNPIMQL37COQ"
AWS_SECRET_ACCESS_KEY = "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"
REPORTS_AWS_BUCKET_NAME = "usasearch-reports"

CALAIS_LICENSE_ID = 'v2yuue4bm3aqkd7w793f834b'

BOT_USER_AGENTS = ["Googlebot", "Baiduspider", "DotBot", "crawler@evreka.com", "bitlybot", "CamontSpider", "CatchBot", "CCBot", "COMODOspider", "ConveraCrawler", "cyberpatrolcrawler", "CydralSpider", "DotSpotsBot", "Educational Crawler", "eventBot", "findfiles.net", "Gigabot", "sai-crawler.callingcard", "ia_archiver", "ICC-Crawler", "ICRA_Semantic_spider", "IssueCrawler", "Jbot", "KIT webcrawler", "KS Crawler", "KSCrawler", "Lijit", "Linguee Bot", "MLBot", "Kwaclebot", "80legs.com/spider.html", "ellerdale.com/crawler.html", "aiHitBot", "archive.org_bot", "cdlwas_bot", "discobot", "Dow Jones Searchbot", "Exabot", "Feedtrace-bot", "foobot", "accelobot.com", "MarketDefenderBot", "MJ12bot", "mxbot", "Purebot", "Reflectbot", "RssFetcherBot", "Search17Bot", "sgbot", "spbot", "Speedy Spider", "woriobot", "xalodotvn-crawler", "YioopBot", "Twiceler", "msnbot", "MSR-ISRCCrawler", "Netchart Adv Crawler", "NetinfoBot", "PicselSpider", "psbot", "R6_FeedFetcher", "radian6_linkcheck_", "SindiceBot", "Snapbot", "Sogou web spider", "Sosospider", "Speedy Spider", "Tasapspider", "the.cyrus.hellborg.sharecrawler", "TurnitinBot", "yacybot", "YaDirectBot", "Yeti", "compatible; ICS"]
