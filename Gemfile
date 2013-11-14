source 'http://rubygems.org'

gem 'rake'
gem 'rails', "3.2.15"
gem 'mysql2', '>0.3'
gem 'capistrano'
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
gem 'aws-s3', :require => 'aws/s3'
gem 'googlecharts'
gem 'sanitize'
gem 'tweetstream'
gem 'twitter'
gem 'flickraw'
gem 'bartt-ssl_requirement', :require => 'ssl_requirement'
gem 'active_scaffold'
gem 'active_scaffold_export'
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
gem 'oj'
gem 'faraday_middleware'
gem 'net-http-persistent'
gem 'rash'
gem 'geoip'
gem 'us_states'
gem 'htmlentities'
gem 'truncate_html'
gem 'addressable'
gem 'select2-rails'
gem 'turbolinks'
gem 'strong_parameters'
gem 'will_paginate-bootstrap'
gem 'virtus'
gem 'keen'
gem 'truncator', :git => 'git://github.com/loren/truncator.git', :branch => 'missing_param_value'
gem 'em-http-request', '~> 1.0'
gem "validate_url"

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'less-rails-bootstrap', '~>2.3'
  gem 'font-awesome-rails'
  gem 'compass-rails'
  gem 'jquery-ui-rails'
  gem 'jquery-rails'
  gem 'therubyracer'
  gem 'yui-compressor'
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
  gem 'shoulda-matchers','~>1.4.0'
  gem 'capybara'
  gem 'launchy'
  gem 'webster'
  gem 'no_peeping_toms', :git => 'git://github.com/patmaddox/no-peeping-toms.git'
  gem 'sunspot_solr', :git => 'git://github.com/GSA-OCSIT/sunspot.git', :ref => "b0af7f90c727ff71804e7608c27882f12670e517"
  gem 'progress_bar'
  gem 'thin'
end

group :test do
  gem 'simplecov', '~> 0.6.4', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'cucumber-rails', :require => false
  gem 'resque_spec'
  gem 'poltergeist'
end
