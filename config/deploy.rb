# config valid for current version and patch releases of Capistrano
lock '~> 3.19.1'

set :application, 'search-gov'
set :branch,      :staging
set :deploy_to,   ENV['DEPLOYMENT_PATH']
set :repo_url,    'https://github.com/GSA/search-gov'
set :format,      :pretty
set :user,        :search

# Use rbenv to manage Ruby versions
set :rbenv_ruby, '3.1.4'
set :rbenv_type, :user

append :linked_dirs,  'log', 'tmp', 'node_modules', 'public'
append :linked_files, '.env', 'config/logindotgov.pem'

set :rails_env,   'production'
set :default_env, { SECRET_KEY_BASE: '1' }

set :resque_environment_task, true

role :resque_worker,    JSON.parse(ENV.fetch('RESQUE_SERVER_ADDRESSES', '[]')), user: ENV['SERVER_DEPLOYMENT_USER']