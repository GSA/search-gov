source 'https://rubygems.org'

gem 'rails', '~> 7.0.0', '>= 7.0.5.1'

gem 'rake', '~> 13.0.6'
gem 'rack-contrib', '~> 2.1.0'
gem 'rails-observers', '~> 0.1.5'
gem 'responders', '~> 3.0.1'
gem 'mysql2', '~> 0.5.0'
gem 'curb', '~> 1.0.1'
gem 'haml', '~> 5.2.1'
gem 'will_paginate', '~> 3.3.0'
gem 'nokogiri', '~> 1.14.3'
gem 'authlogic', '~> 6.4.1'
gem 'omniauth_login_dot_gov', git: 'https://github.com/18f/omniauth_login_dot_gov',
                              ref: '6e117a9c68b19a1fbc70533613b74b0d8affd641'
# It's not clear that this gem is still required. I'm leaving it for the time being,
# but we may be able to remove it in the future:
# https://github.com/omniauth/omniauth/issues/1031
gem 'omniauth-rails_csrf_protection', '~> 1.0.1'
gem 'omniauth', '~> 2.1.0'
gem 'redis', '~> 4.0.1'
gem 'redis-namespace', '~> 1.6.0'
gem 'redis-rails', '~> 5.0.2'
gem 'resque', '~> 1.27.4'
gem 'resque-priority', git: 'https://github.com/GSA/resque-priority.git'
gem 'resque-timeout', '~> 1.0.0'
gem 'resque-lock-timeout', '~> 0.4.5'
gem 'resque-scheduler', '~> 4.3.1'
# Paperclip is deprecated: https://cm-jira.usa.gov/browse/SRCH-702
# Using a third-party fork as an interim measure.
gem 'kt-paperclip', '~> 7.1.0'
gem 'aws-sdk-s3', '~> 1.102.0'
gem 'googlecharts', '~> 1.6.12'
gem 'flickraw', '~> 0.9.9'
# SRCH-3837: We need this change: https://github.com/activescaffold/active_scaffold/pull/666
# for ruby 3, but all current releases require Rails < 6.2 (though main is looser).
gem 'active_scaffold', git: 'https://github.com/activescaffold/active_scaffold',
                       branch: 'master'
# SRCH-3846: We need the change PRed from this branch for ruby 3, but the latest gem release
# has yet to accept the PR: https://github.com/activescaffold/active_scaffold_export/pull/5
gem 'active_scaffold_export', git: 'https://github.com/technorama/active_scaffold_export',
                              branch: 'rails3'
gem 'recaptcha', '~> 4.6.3', require: 'recaptcha/rails'
gem 'newrelic_rpm', '~> 8.12.0'
gem 'american_date', '~> 1.1.1'
# sassc-rails is now the Rails default. Consider replacing:
# https://guides.rubyonrails.org/asset_pipeline.html
gem 'sass-rails', '~> 5.0.7'
# Gem no longer being maintained. See https://cm-jira.usa.gov/browse/SRCH-694
gem 'google_visualr',
    git: 'https://github.com/winston/google_visualr',
    ref: '17b97114a345baadd011e7b442b9a6c91a2b7ab5'
gem 'faraday_middleware', '~> 0.14.0'
gem 'net-http-persistent', '~> 2.9.3'
gem 'rash_alt', '~> 0.4.12', require: 'rash'
gem 'geoip', '~> 1.6.3'
gem 'htmlentities', '~> 4.3.4' # deprecated - only used in Google web search
gem 'html_truncator', '~> 0.4.2'
gem 'addressable', '~> 2.8.0'
gem 'select2-rails', '~> 4.0.3'
gem 'turbolinks', '~> 5.2.1'
gem 'will_paginate-bootstrap', '~> 1.0.1'
gem 'virtus', '~> 1.0.5'
gem 'truncator', '~> 0.1.7'
gem 'validate_url', '= 0.2.0' # Newer versions use Addressable::URI for validation, which is more permissive than what we want
# The elasticsearch gems will be limited to 7.4 until we can remove or upgrade the
# omniauth_login_dot_gov gem, due to its dependency on faraday < 1:
# https://github.com/18F/omniauth_login_dot_gov/blob/main/omniauth_login_dot_gov.gemspec#L28
# We are temporarily using a custom branch in order to access the deprecation logging
# functionality that is available in the official 7.16 release.
gem 'elasticsearch', git: 'https://github.com/GSA/elasticsearch-ruby', branch: '7.4'
gem 'elasticsearch-xpack', '~> 7.4.0'
gem 'federal_register', '~> 0.6.3'
gem 'redcarpet', '~> 3.6'
gem 'google-api-client', '~> 0.53.0'
gem 'iso8601', '~> 0.10.1'
gem 'jbuilder', '~> 2.11.5'
gem 'typhoeus', '~> 1.3.0'
gem 'activerecord-validate_unique_child_attribute',
    require: 'active_record/validate_unique_child_attribute'

gem 'rack-cors', '~> 1.1.0', require: 'rack/cors'
gem 'hashie', '~> 5.0.0'
# retry_block is unsupported - consider replacing with retriable
gem 'retry_block', '~> 1.2.0'
gem 'colorize', '~> 0.8.1'
gem 'dogstatsd-ruby', '~> 3.2.0'
gem 'http', '~> 5.0'
gem 'robots_tag_parser', '~> 0.1.0'
gem 'loofah', '~> 2.19.1'
# Locking ref, as later versions (after being renamed & released as "medusa-crawler")
# include breaking changes
gem 'medusa', git: 'https://github.com/brutuscat/medusa-crawler',
              ref: '82299f2700ac56b4af2b14d707f35d6af466ad8e'
# Robotex is required by Medusa. Specifying fork until https://github.com/chriskite/robotex/issues/4
# is resolved
gem 'robotex', git: 'https://github.com/GSA/robotex'
gem 'saxerator', '~> 0.9.9'
gem 'counter_culture', '~> 2.9.0'
# after_commit_action needed to enable counter_culture's execute_after_commit option.
gem 'after_commit_action', '~> 1.1'
gem 'aasm', '~> 5.5'
gem 'active_scheduler', '~> 0.7.0'
gem 'retriable', '~> 3.1'
gem 'cld3', '~> 3.5.0'
gem 'activejob-uniqueness', '~> 0.2.1'
# Temporarily locking the version to resolve SRCH-3788.
# The fix for the bug in SRCH-3788 is NOT covered by automated specs.
# A spec will be added (if possible) per SRCH-3790
gem 'selenium-webdriver', '4.7.1'
gem 'exception_notification', '~> 4.5'
gem 'dogapi', '~> 1.45'
# Temporary fix to remove warnings seen in Rails 7:
# https://github.com/ruby/net-protocol/issues/10
# This gem can be removed once we upgrade to Ruby 3.1.
gem 'net-http'

# Assets-related gems
gem 'coffee-rails', '~> 5.0.0'
gem 'uglifier', '~> 4.2.0'
gem 'compass-rails', '~> 4.0.0'
gem 'compass-blueprint', '~> 1.0.0'
gem 'jquery-ui-rails', '~> 6.0.1'
gem 'jquery-rails', '~> 4.4.0'
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
gem 'react-rails', '~> 2.7.0'
# Locking to prevent a version mismatch between the gem and the NPM package version
# See https://github.com/shakacode/shakapacker#upgrading
gem 'shakapacker', '6.5.4'
gem 'cssbundling-rails', '~> 1.2' # Management of css (Less) files conversion

# Temporarily locking the 'mail' version until the next version of Rails is released
# https://github.com/rails/rails/pull/46650
gem 'mail', '~> 2.7.1'
gem 'feedjira', '~> 3.2'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring', '~> 3.1'
  # Bumping searchgov_style? Be sure to update rubocop, if possible,
  # and the Rubocop channel in .codeclimate.yml to match the updated rubocop version
  gem 'searchgov_style', '~> 0.1', require: false
  gem 'rubocop', '1.48.1', require: false
  # Use console on exceptions pages [https://github.com/rails/web-console]
  # gem 'web-console'
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"
end

group :development, :test do
  gem 'rspec-rails', '~> 5.0'
  gem 'rspec-its', '~> 1.3'
  gem 'email_spec', '~> 2.2'
  gem 'database_cleaner', '~> 2.0'
  gem 'capybara', '~> 3.26'
  gem 'launchy', '~> 2.5'
  gem 'i18n-tasks', '~> 0.9.19'
  gem 'pry-byebug', '~> 3.5'
  gem 'faker', '~> 1.8'
  gem 'pry-rails', '~> 0.3.6'
  # For improved console readability:
  # https://github.com/amazing-print/amazing_print
  gem 'amazing_print', '~> 1.4'
  gem 'puma', '~> 5.3'
  gem 'debug'
  gem 'bootsnap', '~> 1.13', require: 'bootsnap/setup'
end

group :test do
  gem 'axe-core-capybara'
  gem 'axe-core-cucumber'
  gem 'capybara-screenshot'
  gem 'cucumber-rails', '~> 2.4', require: false
  gem 'cucumber', '~> 7.1', require: false
  gem 'rails-controller-testing', '~> 1.0'
  # resque-spec hasn't been supported since 2018. Consider replacing with equivalent
  # functionality from rspec-rails: https://relishapp.com/rspec/rspec-rails/v/5-0/docs/job-specs/job-spec
  gem 'resque_spec', '~> 0.18.0'
  gem 'rspec_junit_formatter', '~> 0.4'
  gem 'rspec-activemodel-mocks', '~> 1.1'
  gem 'shoulda-kept-assign-to', '~> 1.1'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', '~> 0.17.0', require: false
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~> 3.8'
end
