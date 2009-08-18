# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  config.gem "haml", :version => '2.2.2'
  config.gem "json", :version => '>= 1.1.7'
  config.gem "valda-gweb_search", :lib => 'google/gweb_search', :source => 'http://gems.github.com', :version => '>= 1.0.0'
  config.gem 'mislav-will_paginate', :version => '~> 2.3.11', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem "chriseppstein-compass", :lib => 'compass', :source => 'http://gems.github.com', :version => '>= 0.8.9'
  config.gem "hpricot"
  config.gem "rspec",            :lib => false
  config.gem "rspec-rails",      :lib => false
  config.gem "remarkable_rails", :lib => false
  
  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
end