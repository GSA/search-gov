# config valid for current version and patch releases of Capistrano
lock '~> 3.19.1'

set :application,             'search-gov'
set :branch,                  ENV.fetch('SEARCH_ENV', 'staging')
set :default_env,             { SECRET_KEY_BASE: '1' }
set :deploy_to,               ENV['DEPLOYMENT_PATH']
set :format,                  :pretty
set :puma_access_log,         "#{release_path}/log/puma.access.log"
set :puma_bind,               'tcp://0.0.0.0:3300'
set :puma_error_log,          "#{release_path}/log/puma.error.log"
set :rails_env,               'production'
set :rbenv_ruby,              '3.1.4'
set :rbenv_type,              :user
set :repo_url,                'https://github.com/GSA/search-gov'
set :resque_environment_task, true
set :user,                    ENV['SERVER_DEPLOYMENT_USER']
set :whenever_roles,          :cron
set :workers,                 { '*' => ENV.fetch('RESQUE_WORKERS_COUNT', '5').to_i }

append :linked_dirs,  'log', 'tmp', 'node_modules', 'public'
append :linked_files, '.env', 'config/logindotgov.pem'

role :app,           JSON.parse(ENV.fetch('APP_SERVER_ADDRESSES', '[]')),    user: ENV['SERVER_DEPLOYMENT_USER']
role :cron,          JSON.parse(ENV.fetch('CRON_SERVER_ADDRESSES', '[]')),   user: ENV['SERVER_DEPLOYMENT_USER']
role :db,            JSON.parse(ENV.fetch('APP_SERVER_ADDRESSES', '[]')),    user: ENV['SERVER_DEPLOYMENT_USER']
role :resque_worker, JSON.parse(ENV.fetch('RESQUE_SERVER_ADDRESSES', '[]')), user: ENV['SERVER_DEPLOYMENT_USER']
role :web,           JSON.parse(ENV.fetch('APP_SERVER_ADDRESSES', '[]')),    user: ENV['SERVER_DEPLOYMENT_USER']

set :ssh_options, {
  auth_methods:  %w(publickey),
  forward_agent: false,
  keys:          [ENV['SSH_KEY_PATH']],
  user:          ENV['SERVER_DEPLOYMENT_USER'],
}
