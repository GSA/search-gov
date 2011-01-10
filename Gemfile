source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '2.3.4'
gem "haml", '2.2.3'
gem 'mysql'
gem "json", '>= 1.4.3'
gem 'sinatra', '0.9.2'

gem 'sunspot',  '1.1.0'
gem 'sunspot_rails', '1.1.0', :require => 'sunspot/rails'

gem "chriseppstein-compass", '>= 0.8.9', :require => 'compass'
gem "calendar_date_select", '>= 1.16.1'

gem "bcrypt-ruby", '>= 2.1.1', :require => "bcrypt"
gem "authlogic", '>= 2.1.5'

gem "libxml-ruby", '=1.1.4', :require => "xml/libxml"
gem "yajl-ruby", '= 0.7.8', :require => 'yajl'

gem "redis", '= 2.1.1'
gem "redis-namespace"
gem "resque", '= 1.10.0'

gem 'capistrano'
gem 'capistrano-ext'

gem 'hoptoad_notifier', '2.3.4'

gem 'mislav-will_paginate', '~> 2.3.11', :require => 'will_paginate'
gem "hpricot", '>= 0.8.2'
gem 'schoefmax-multi_db', :require => 'multi_db'
gem 'fastercsv', '1.5.3'
gem 'calais', '>= 0.0.11'
gem "aws-s3", '0.6.2', :require => "aws/s3"
gem "noaa", '=0.2.4'
gem "SystemTimer", '=1.2'

group :development do
  gem 'dancroak-webster', :require => 'webster'
end

group :development, :test, :cucumber do
  gem 'ruby-debug'
  gem 'rspec'
  gem 'rspec-rails'
end

group :test, :cucumber do
  gem "cucumber", '>= 0.10.0'
  gem "cucumber-rails", '>= 0.3.2'
  gem 'email_spec', '~> 0.6.0',      :require => 'email_spec'
  gem 'webrat', '>=0.7.0'
end

group :test do
  gem "remarkable_rails", '>= 3.1.10'
  gem "nokogiri"
  gem "rcov"
  gem "resque_spec",  '~> 0.2.0'
end


group :cucumber do
  gem 'database_cleaner', '>=0.5.0'
end
