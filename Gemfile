source 'http://rubygems.org'

gem 'rake', "0.9.2.2"
gem 'rails', "3.2.8"
gem 'mysql2', '>0.3'
gem 'capistrano', :git => 'git://github.com/GSA-OCSIT/capistrano.git'
gem 'capistrano-ext'
gem 'jquery-rails'
gem 'haml'
gem 'json'
gem 'will_paginate'
gem 'nokogiri'
gem 'calendar_date_select', :git => 'git://github.com/paneq/calendar_date_select.git'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'authlogic'
gem 'multi_db'
gem 'sunspot_rails', :git => 'git://github.com/GSA-OCSIT/sunspot.git', :ref => "b0af7f90c727ff71804e7608c27882f12670e517"
gem 'airbrake'
gem 'yajl-ruby', :require => 'yajl'
gem 'redis'
gem 'redis-namespace'
gem 'resque'
gem 'resque-priority', :git => 'git://github.com/GSA-OCSIT/resque-priority.git'
gem 'cloudfiles', '1.4.17'
gem 'cocaine', '~> 0.3.2'
gem 'paperclip-cloudfiles', :require => 'paperclip'
gem 'sauce'
gem 'parallel'
gem 'aws-s3', :require => 'aws/s3', :git => 'git://github.com/GSA-OCSIT/aws-s3.git'
gem 'high_voltage'
gem 'mechanize'
gem 'googlecharts'
gem 'sanitize'
gem 'tweetstream'
gem 'twitter'
gem 'flickraw'
gem 'bartt-ssl_requirement', :require => 'ssl_requirement'
gem 'active_scaffold', :git => 'git://github.com/activescaffold/active_scaffold.git'
gem 'render_component_vho', :git => 'git://github.com/vhochstein/render_component.git'
gem 'recordselect', :git => 'git://github.com/scambra/recordselect.git'
gem 'active_scaffold_export', :git => 'git://github.com/naaano/active_scaffold_export.git'
gem 'us_states_select', :git => 'git://github.com/jeremydurham/us-state-select-plugin.git', :require => 'us_states_select'
gem 'mobile-fu'
gem 'rspec'
gem 'rspec-core'
gem 'cucumber'
gem "recaptcha", :require => "recaptcha/rails"
gem 'dynamic_form'
gem 'newrelic_rpm'
gem 'american_date'
gem 'sass'
gem "google_visualr"

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'compass'
  gem 'compass-rails'
  gem 'execjs'
  gem 'libv8', '~> 3.11.8'
  gem 'therubyracer', :require => 'v8'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'webrat'
  gem 'rspec-rails'
  gem 'remarkable_activerecord'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'capybara', '~>1.1'
  gem 'launchy'
  gem 'webster'
  gem 'no_peeping_toms', :git => 'git://github.com/patmaddox/no-peeping-toms.git'
  gem 'sunspot_solr', :git => 'git://github.com/GSA-OCSIT/sunspot.git', :ref => "b0af7f90c727ff71804e7608c27882f12670e517"
  gem 'progress_bar'
  gem 'thin'
  gem 'ruby-prof'
end

group :test do
  gem 'simplecov', '~> 0.6.4', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'cucumber-rails', :require => false
  gem 'resque_spec'
end
