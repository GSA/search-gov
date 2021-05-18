source 'https://rubygems.org'

gem 'rails', '~> 5.2.0'

gem 'rake', '~> 12.3.2'
gem 'rack-contrib', '~> 2.1.0'
gem 'rails-observers', '~> 0.1.5'
gem 'responders', '~> 2.0'
gem 'mysql2', '~> 0.4.4'
gem 'curb', '~> 0.9.4'
gem 'haml', '~> 5.0.4'
gem 'will_paginate', '~> 3.1.6'
gem 'nokogiri', '~> 1.11.4'
gem 'bcrypt-ruby', '~> 3.1.5', :require => 'bcrypt'
gem 'authlogic', '~> 3.8.0'
# Temporarily locking gem to specific ref. Newer versions include incompatible gems
gem 'omniauth_login_dot_gov', git: 'https://github.com/18f/omniauth_login_dot_gov',
                              ref: '08ce9b5322efb2d82b2df3f6d774308c4028ee6c'
gem 'omniauth-rails_csrf_protection', '~> 0.1.2'
gem 'airbrake', '~> 7.1.1'
gem 'redis', '~> 4.0.1'
gem 'redis-namespace', '~> 1.6.0'
gem 'redis-rails', '~> 5.0.2'
gem 'resque', '~> 1.27.4'
gem 'resque-priority', :git => 'https://github.com/GSA/resque-priority.git'
gem 'resque-timeout', '~> 1.0.0'
gem 'resque-lock-timeout', '~> 0.4.5'
gem 'resque-scheduler', '~> 4.3.1'
gem 'paperclip', '~> 5.2.0'
gem 'googlecharts', '~> 1.6.12'
gem 'tweetstream', '~> 2.6.1' # no longer maintained?
gem 'twitter', git: 'https://github.com/GSA/twitter.git', branch: '5-stable'
gem 'flickraw', '~> 0.9.9'
gem 'active_scaffold', '~> 3.5.0'
gem 'active_scaffold_export', git: 'https://github.com/naaano/active_scaffold_export'
gem 'mobile-fu', '~> 1.4.0' # deprecated - legacy SERP
gem "recaptcha", '~> 4.6.3', :require => "recaptcha/rails"
gem 'newrelic_rpm', '~> 5.0.0'
gem 'american_date', '~> 1.1.1'
gem 'sass', '~> 3.3.0'
gem 'sass-rails', '~> 5.0.7'
# Gem no longer being maintained. See https://cm-jira.usa.gov/browse/SRCH-694
gem 'google_visualr',
    git: 'https://github.com/winston/google_visualr',
    ref: '17b97114a345baadd011e7b442b9a6c91a2b7ab5'
gem 'faraday_middleware', '~> 0.12.2'
gem 'net-http-persistent', '~> 2.9.3'
gem 'rash_alt', git: 'https://github.com/MothOnMars/rash_alt', ref: 'bbd107061fbb066709523c68de4a217a76a8a945', require: 'rash'
gem 'geoip', '~> 1.6.3'
gem 'htmlentities', '~> 4.3.4' # deprecated - only used in Google web search
gem 'html_truncator', '~> 0.4.2'
gem 'addressable', '~> 2.5.2'
gem 'select2-rails', '~> 4.0.3'
gem 'turbolinks', '~> 5.0.1'
gem 'will_paginate-bootstrap', '~> 1.0.1'
gem 'virtus', '~> 1.0.5'
gem 'truncator', '~> 0.1.7'
gem 'em-http-request', '~> 1.1.5'
gem "validate_url", '= 0.2.0' # Newer versions use Addressable::URI for validation, which is more permissive than what we want
gem 'elasticsearch', '~> 7.4.0'
gem 'elasticsearch-xpack', '~> 7.4.0'
gem 'federal_register', '~> 0.6.3'
gem 'github-markdown', '~> 0.6.9'
gem 'google-api-client', '~> 0.19.1'
gem 'iso8601', '~> 0.10.1'
gem 'jbuilder', '~> 2.6.4'
gem 'sitelink_generator', git: 'https://github.com/GSA/sitelink_generator', ref: '2f78cd142547a2a87e500266f1ef4eb5e281cc6b'
gem 'typhoeus', '~> 1.3.0'
gem 'activerecord-validate_unique_child_attribute',
    require: 'active_record/validate_unique_child_attribute'
# deprecated - jwt, grape, and grape-entity are only used by Search Consumer
gem 'jwt', '~> 1.5.6'
gem 'grape', '~> 1.1'
gem 'grape-entity', '~> 0.6.0'
gem 'rack-cors', '~> 1.1.0', :require => 'rack/cors'
gem 'hashie', '~> 3.3.0'
gem 'retry_block', '~> 1.2.0'
gem 'aws-sdk', '< 3.0'
gem 'colorize', '~> 0.8.1'
gem 'dogstatsd-ruby', '~> 3.2.0'
gem 'http', '~> 1.0'
gem 'robots_tag_parser', '~> 0.1.0', git: 'https://github.com/GSA/robots_tag_parser'
gem 'loofah', '~> 2.9.0'
# Locking ref, as later versions (after being renamed & released as "medusa-crawler")
# include breaking changes
gem 'medusa', git: 'https://github.com/brutuscat/medusa-crawler',
              ref: '82299f2700ac56b4af2b14d707f35d6af466ad8e'
# Robotex is required by Medusa. Specifying fork until https://github.com/chriskite/robotex/issues/4
# is resolved
gem 'robotex', git: 'https://github.com/MothOnMars/robotex'
gem 'saxerator', '~> 0.9.9'
gem 'counter_culture', '~> 2.3.0'
gem 'aasm', '~> 4.12'
gem 'active_scheduler', '~> 0.5.0'
gem 'retriable', '~> 3.1'
gem 'cld3', '~> 3.2.3'

# Assets-related gems
gem 'coffee-rails', '~> 4.2.2'
gem 'uglifier', '~> 4.1.2'
gem 'less-rails-bootstrap', git: 'https://github.com/GSA/less-rails-bootstrap.git',
                            branch: 'master'
gem 'compass-rails', '~> 3.1.0'
gem 'compass-blueprint', '~> 1.0.0'
gem 'jquery-ui-rails', '~> 6.0.1'
gem 'jquery-rails', '~> 4.4.0'
gem 'therubyracer', '~> 0.12.3'
gem 'yui-compressor', '~> 0.12.0'
gem 'twitter-typeahead-rails', '~> 0.11.1'
# Why do we have two versions of Font Awesome?
# One is for general use around the app, in places where
# web fonts are expected to work...
gem 'font-awesome-rails', '~> 4.7.0'
# ... and one is for the admin area only, where web fonts
# may be blocked due to government security policy. For
# this area we use a restricted subset of Font Awesome 4.3.x
# icons compiled into SVG/CSS+PNG using Grunticon. See
# https://github.com/gsa/font-awesome-grunticon-rails
# for instructions on how to add more icons to this set
gem 'font-awesome-grunticon-rails',
    git: 'https://github.com/gsa/font-awesome-grunticon-rails',
    ref: '8ad9734a65f7e2d2de934bebe4ee7b460734f96e'
# execjs 2.8 removed support for therubyracer:
# https://github.com/rails/execjs/releases/tag/v2.8.0
# Locking the version to 2.7.x until we remove or replace therubyracer
gem 'execjs', '~> 2.7.0'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development do
  gem 'spring', '~> 2.0'
  gem 'listen', '~> 3.1.5'
  # Bumping searchgov_style? Be sure to update the Rubocop channel in .codeclimate.yml
  # to match the channel in searchgov_style
  gem 'searchgov_style', '~> 0.1', require: false
end

group :development, :test do
  gem 'rspec-rails', '~> 3.8.2'
  gem 'rspec-json_expectations', '~> 2.1.0'
  gem 'rspec-its', '~> 1.2.0'
  gem 'email_spec', '~> 2.1.1'
  gem 'database_cleaner', '~> 1.7.0'
  gem 'capybara', '~> 2.18.0'
  gem 'launchy', '~> 2.4.3'
  gem 'i18n-tasks', '~> 0.9.19'
  gem 'pry-byebug', '~> 3.5'
  gem 'faker', '~> 1.8'
  gem 'pry-rails', '~> 0.3.6'
  gem 'awesome_print'
  gem 'puma', '~> 3.12'
end

group :test do
  gem 'capybara-screenshot'
  gem 'simplecov', '~> 0.17.0', require: false
  # Limiting the cucumber version until v4 is compatible with VCR
  # https://github.com/vcr/vcr/issues/825
  gem 'cucumber', '~> 3.0', require: false
  gem 'cucumber-rails', '~> 2.0', require: false
  gem 'resque_spec', '~> 0.17.0'
  gem 'poltergeist', '~> 1.18.1'
  gem 'shoulda-matchers', '~> 4.1.1'
  gem 'shoulda-kept-assign-to', '~> 1.1.0'
  gem 'vcr', '~> 4.0'
  gem 'webmock', '~> 3.8.3'
  gem 'rspec-activemodel-mocks', '~> 1.0.3'
  gem 'rspec_junit_formatter', '~> 0.3.0'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'webdrivers', '~> 4.0'
end
