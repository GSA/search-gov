source 'https://rubygems.org'

# Temporarily limiting rake version:
# #http://stackoverflow.com/questions/35893584/nomethoderror-undefined-method-last-comment-after-upgrading-to-rake-11
gem 'rake', '~> 10.0'
gem 'rails', "3.2.22.1"
gem 'mysql2', '>0.3'
gem 'capistrano'
gem 'curb'
gem 'haml'
gem 'json'
gem 'will_paginate'
gem 'nokogiri'
gem 'calendar_date_select', :git => 'git://github.com/paneq/calendar_date_select.git'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'authlogic'
gem 'airbrake'
gem 'yajl-ruby', :require => 'yajl'
gem 'redis'
gem 'redis-namespace'
gem 'redis-rails'
gem 'resque'
gem 'resque-priority', :git => 'git://github.com/GSA/resque-priority.git'
gem 'resque-timeout'
gem 'resque-lock-timeout'
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
gem 'html_truncator'
gem 'addressable'
gem 'select2-rails'
gem 'turbolinks'
gem 'strong_parameters'
gem 'will_paginate-bootstrap'
gem 'virtus', '~> 1.0.0'
gem 'keen'
gem 'truncator'
gem 'em-http-request', '~> 1.0'
gem "validate_url"
gem 'elasticsearch'
gem 'elasticsearch-watcher'
gem 'federal_register'
gem 'github-markdown'
gem 'google-api-client'
gem 'instagram'
gem 'iso8601'
gem 'jbuilder'
gem 'rack-contrib'
gem 'sitelink_generator'
gem 'typhoeus'
gem 'mandrill-api'
gem 'activerecord-validate_unique_child_attribute', require: 'active_record/validate_unique_child_attribute'
gem 'jwt'
gem 'grape', '~> 0.13.0'
gem 'grape-entity'
gem 'rack-cors', :require => 'rack/cors'
gem 'hashie', '~> 2.1.0'
gem 'retry_block'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'less-rails-bootstrap'
  gem 'compass-rails'
  gem 'jquery-ui-rails'
  gem 'jquery-rails'
  gem 'therubyracer', '~> 0.12.2'
  gem 'yui-compressor'
  gem 'twitter-typeahead-rails', '~> 0.11.1'
  # Why do we have two versions of Font Awesome?
  # One is for general use around the app, in places where
  # web fonts are expected to work...
  gem 'font-awesome-rails', '~> 3.2.1.3'
  # ... and one is for the admin area only, where web fonts
  # may be blocked due to government security policy. For
  # this area we use a restricted subset of Font Awesome 4.3.x
  # icons compiled into SVG/CSS+PNG using Grunticon. See
  # https://github.com/gsa/font-awesome-grunticon-rails
  # for instructions on how to add more icons to this set
  gem 'font-awesome-grunticon-rails', git: 'git://github.com/gsa/font-awesome-grunticon-rails', ref: 'f79a656ac17a8cbd1fe34f7a0336692b5c2371c3'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'webrat'
  gem 'rspec-rails', '2.14'
  gem 'rspec-json_expectations'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'launchy'
  gem 'no_peeping_toms', :git => 'git://github.com/patmaddox/no-peeping-toms.git'
  gem 'thin'
  gem 'i18n-tasks', '~> 0.7.13'
  gem 'pry-byebug'
  gem 'rubocop'
  gem 'faker'
end

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'simplecov', '~> 0.10.0', require:  false # limiting version until we determine why bumping to 0.11.* makes our coverage % drop
  gem 'cucumber-rails', :require => false
  gem 'resque_spec'
  gem 'poltergeist'
  gem 'shoulda-matchers','~>1.4.0'
  gem 'vcr', '~> 3.0'
  gem 'webmock', '~> 2.0'
end
