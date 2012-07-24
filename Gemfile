source 'http://rubygems.org'

gem 'rails', "3.2.6"
gem 'mysql2', '>0.3'
gem 'capistrano', :git => 'git://github.com/GSA-OCSIT/capistrano.git'
gem 'capistrano-ext'
gem 'jquery-rails'
gem 'haml'
gem 'json'
gem 'will_paginate', '~> 3.0'
gem 'hpricot', '>= 0.8.2'
gem 'nokogiri', '>= 1.5.2'
gem 'calendar_date_select', :git => 'git://github.com/paneq/calendar_date_select.git'
gem 'bcrypt-ruby', '>= 2.1.1', :require => 'bcrypt'
gem 'authlogic', '>=3.0.2'
gem 'multi_db'
gem 'sunspot_rails', :git => 'git://github.com/GSA-OCSIT/sunspot.git', :ref => "2bc9627ba6d0ca36c68ab579b1ea521415b3b1a5"
gem 'airbrake'
gem 'fastercsv'
gem 'yajl-ruby', :require => 'yajl'
gem 'redis', '= 2.1.1'
gem 'redis-namespace'
gem 'resque'
gem 'resque-priority', :git => 'git://github.com/GSA-OCSIT/resque-priority.git'
gem 'cloudfiles', :git => 'git://github.com/GSA-OCSIT/ruby-cloudfiles.git', :branch => 'escaped_name'
gem 'cocaine'
gem 'paperclip-cloudfiles', :require => 'paperclip'
gem 'sauce'
gem 'parallel'
gem 'aws-s3', :require => 'aws/s3', :git => 'git://github.com/GSA-OCSIT/aws-s3.git'
gem 'SystemTimer'
gem 'high_voltage'
gem 'backports'
gem 'mechanize'
gem 'googlecharts'
gem 'sanitize'
gem 'tweetstream', "=1.1.4"
gem 'twitter'
gem 'flickraw'
gem 'bartt-ssl_requirement', '~>1.4.0', :require => 'ssl_requirement'
gem 'active_scaffold', :git => 'git://github.com/activescaffold/active_scaffold.git', :branch => 'rails-3.2'
gem 'render_component_vho', :git => 'git://github.com/vhochstein/render_component.git'
gem 'recordselect', :git => 'git://github.com/scambra/recordselect.git'
gem 'active_scaffold_export', :git => 'git://github.com/naaano/active_scaffold_export.git'
gem 'us_states_select', :git => 'git://github.com/jeremydurham/us-state-select-plugin.git', :require => 'us_states_select'
gem 'mobile-fu'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'compass'
  gem 'compass-rails'
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
  gem 'capybara'
  gem 'cucumber'
  gem 'launchy'
  gem 'rcov'
  gem 'webster'
#  gem 'rack-perftools_profiler', :require => 'rack/perftools_profiler'
  gem 'no_peeping_toms', :git => 'git://github.com/leereilly/no-peeping-toms.git', :branch => "fix-instancemethods-deprecation-warning"
  gem 'sunspot_solr', :git => 'git://github.com/GSA-OCSIT/sunspot.git', :ref => "2bc9627ba6d0ca36c68ab579b1ea521415b3b1a5"
  gem 'progress_bar'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'resque_spec'
end