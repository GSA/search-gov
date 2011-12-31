source 'http://rubygems.org'

gem 'rake', '~> 0.8.7'
gem 'rails', "3.0.10"

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2', '< 0.3'

# Deploy with Capistrano
gem 'capistrano', :git => 'git://github.com/GSA-OCSIT/capistrano.git'
gem 'capistrano-ext'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'haml'
gem 'sass'
gem 'json'
gem 'will_paginate', '~> 3.0.pre2'
gem 'compass'
gem 'hpricot', '>= 0.8.2'
gem 'nokogiri', '>= 1.4.4'
gem 'calendar_date_select', :git => 'git://github.com/paneq/calendar_date_select.git'
gem 'bcrypt-ruby', '>= 2.1.1', :require => 'bcrypt'
gem 'authlogic', '>=3.0.2'
gem 'multi_db', :git => 'git://github.com/GSA-OCSIT/multi_db.git'
gem 'sunspot_rails'
gem 'airbrake'
gem 'fastercsv'
gem 'yajl-ruby', :require => 'yajl'
gem 'redis', '= 2.1.1'
gem 'redis-namespace'
gem 'resque'
gem 'cloudfiles'
gem 'paperclip'
gem 'paperclip-cloudfiles', :require => 'paperclip'
gem 'sauce'
gem 'parallel'
gem 'aws-s3', :require => 'aws/s3', :git => 'git://github.com/GSA-OCSIT/aws-s3.git'
gem 'SystemTimer'
gem 'high_voltage'
gem 'backports'
gem 'mechanize'
gem 'pdf-toolkit'
gem 'googlecharts'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test, :cucumber do
  gem 'webrat'
  gem 'rspec'
  gem 'rspec-core'
  gem 'rspec-rails'
  gem 'remarkable_activerecord'
  gem 'email_spec'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'capybara'
  gem 'cucumber'
  gem 'launchy'
  gem 'rcov'
  gem 'webster'
#  gem 'rack-perftools_profiler', :require => 'rack/perftools_profiler'
  gem 'no_peeping_toms', :git => 'git://github.com/alindeman/no_peeping_toms.git'
end

group :test do
  gem 'resque_spec'
end
