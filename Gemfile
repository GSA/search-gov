source 'https://rubygems.org'

# Temporarily limiting rake version:
# #http://stackoverflow.com/questions/35893584/nomethoderror-undefined-method-last-comment-after-upgrading-to-rake-11
gem 'rake', '~> 10.0'
gem 'rails', "3.2.22.5"
gem 'mysql2', '~> 0.3.0' #mysql2 0.4.x works with Rails / Active Record 4.2.5 - 5.0+
gem 'capistrano', '~> 3.8.2'
gem 'curb', '~> 0.9.3'
gem 'haml', '~> 4.0.3'
gem 'json', '~> 1.8.6'
gem 'will_paginate', '~> 3.1.0'
gem 'nokogiri', '~> 1.8.0'
gem 'calendar_date_select', git: 'https://github.com/paneq/calendar_date_select.git'
gem 'bcrypt-ruby', '~> 3.1.5', :require => 'bcrypt'
gem 'authlogic', '~> 3.6.0'
gem 'airbrake', '~> 4.1.0'
gem 'yajl-ruby', '~> 1.3.0', :require => 'yajl'
gem 'redis', '~> 3.2.2'
gem 'redis-namespace', '~> 1.5.2'
gem 'redis-rails', '~> 3.2.4'
gem 'resque', '~> 1.25.2'
gem 'resque-priority', :git => 'https://github.com/GSA/resque-priority.git'
gem 'resque-timeout', '~> 1.0.0'
gem 'resque-lock-timeout', '~> 0.4.4'
gem 'cocaine', '~> 0.5.8'
gem 'paperclip' , '~> 4.3.7' # 5.0 requires Rails >= 4.2
gem 'googlecharts', '~> 1.6.8'
gem 'sanitize', '~> 2.1.0'
gem 'tweetstream', '~> 2.6.1' #no longer maintained?
gem 'twitter', '~> 5.5'
gem 'flickraw', '~> 0.9.9'
gem 'bartt-ssl_requirement', '~> 1.4.2', :require => 'ssl_requirement'
gem 'active_scaffold', '3.3.1'
gem 'active_scaffold_export', '~> 3.3.0'
gem 'us_states_select', :git => 'https://github.com/jeremydurham/us-state-select-plugin.git', :require => 'us_states_select'
gem 'mobile-fu', '~> 1.2.1'
gem "recaptcha", "~> 4.1.0", :require => "recaptcha/rails"
gem 'dynamic_form', '~> 1.1.4'
gem 'newrelic_rpm', '~> 3.6.5.130'
gem 'american_date', '~> 1.1.0'
gem 'sass', '~> 3.2.9'
gem "google_visualr", '~> 2.1.7'
gem 'oj', '~> 2.1.3'
gem 'faraday_middleware', '~> 0.9.2'
gem 'net-http-persistent', '~> 2.9.4'
gem 'rash_alt', git: 'https://github.com/MothOnMars/rash_alt', branch: 'mct/hashie_version', require: 'rash'
gem 'geoip', '~> 1.5.0'
gem 'us_states', '~> 0.1.1'
gem 'htmlentities', '~> 4.3.1'
gem 'html_truncator', '~> 0.3.1'
gem 'addressable', '~> 2.3.8'
gem 'select2-rails', '~> 3.4.3'
gem 'turbolinks', '~> 1.3.0'
gem 'strong_parameters', '~> 0.2.3'
gem 'will_paginate-bootstrap', '~> 0.2.4'
gem 'virtus', '~> 1.0.0'
gem 'keen', '~> 0.8.0'
gem 'truncator', '~> 0.1.6'
gem 'em-http-request', '~> 1.0'
gem "validate_url", '~> 0.2.0'
gem 'elasticsearch', '~> 1.0.13'
gem 'elasticsearch-watcher', '~> 0.0.1'
gem 'federal_register', '~> 0.5.1'
gem 'github-markdown', '~> 0.6.7'
gem 'google-api-client', '~> 0.8.6'
gem 'instagram', '~> 1.1.6'
gem 'iso8601', '~> 0.8.6'
gem 'jbuilder', '~> 1.0.2'
gem 'rack-contrib', '~> 1.2.0'
gem 'sitelink_generator', '~> 0.3.0'
gem 'typhoeus', '~> 1.1.2'
gem 'mandrill-api', '~> 1.0.53'
gem 'activerecord-validate_unique_child_attribute', '~> 0.0.2', require: 'active_record/validate_unique_child_attribute'
gem 'jwt', '~> 1.4.1'
gem 'grape', '~> 0.18.0'
gem 'grape-entity', '~> 0.4.8'
gem 'rack-cors', '~> 0.4.0', :require => 'rack/cors'
gem 'hashie', '~> 3.3.0'
gem 'retry_block', '~> 1.2.0'
gem 'aws-sdk', '~> 1.67.0'
gem 'colorize', '~> 0.8.1'
gem 'dogstatsd-ruby', '~> 2.1.0'
gem 'lograge', '~> 0.3.6'
gem 'test-unit', '~> 3.2.4'
gem 'http', '~> 1.0.0'
gem 'public_suffix', '~> 2.0.0'
gem 'robots_tag_parser', git: 'https://github.com/GSA/robots_tag_parser'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'less-rails-bootstrap', '~> 3.0.6'
  gem 'compass-rails', '~> 1.0.3'
  gem 'jquery-ui-rails', '~> 5.0.5'
  gem 'jquery-rails', '~> 3.1.4'
  gem 'therubyracer', '~> 0.12.2'
  gem 'yui-compressor', '~> 0.12.0'
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
  gem 'font-awesome-grunticon-rails', git: 'https://github.com/gsa/font-awesome-grunticon-rails', ref: 'f79a656ac17a8cbd1fe34f7a0336692b5c2371c3'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'webrat', '~> 0.7.3'
  gem 'rspec-rails', '2.99'
  gem 'rspec-json_expectations', '~> 1.3.0'
  gem 'rspec-its', '~> 1.0.1'
  gem 'email_spec', '~> 1.6.0'
  gem 'database_cleaner', '~> 1.6.1'
  gem 'capybara', '~> 2.15.1'
  gem 'launchy', '~> 2.4.3'
  gem 'thin', '~> 1.7.0'
  gem 'i18n-tasks', '~> 0.7.13'
  gem 'pry-byebug', '~> 3.4.2'
  gem 'rubocop', '~> 0.38.0'
  gem 'faker', '~> 1.7.3'
  gem 'pry-rails', '~> 0.3.4'
  gem 'awesome_print', '~> 1.8.0'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 0.2.0', require: false
  gem 'simplecov', '~> 0.10.0', require:  false # limiting version until we determine why bumping to 0.11.* makes our coverage % drop
  gem 'cucumber-rails', '~> 1.4.5', :require => false
  gem 'resque_spec', '~> 0.15.0'
  gem 'poltergeist', '~> 1.16.0'
  gem 'shoulda-matchers', '~> 2.8.0'
  gem 'shoulda-kept-assign-to', '~> 1.1.0'
  gem 'vcr', '~> 3.0'
  gem 'webmock', '~> 3.0.1'
  gem 'rspec-activemodel-mocks', '~> 1.0.3'
  gem 'timecop', '~> 0.8.1'
  gem 'rspec_junit_formatter', '~> 0.2.3'
end
