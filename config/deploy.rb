# config valid for current version and patch releases of Capistrano
lock '~> 3.19.1'

require 'securerandom'
require 'shellwords'

SEARCHGOV_THREADS = ENV.fetch('SEARCHGOV_THREADS') { 5 }

set :application,             'search-gov'
set :branch,                  ENV.fetch('SEARCH_ENV', 'staging')
set :default_env,             { SECRET_KEY_BASE: '1' }
set :deploy_to,               ENV['DEPLOYMENT_PATH']
set :format,                  :pretty
set :puma_access_log,         "#{release_path}/log/puma.access.log"
set :puma_bind,               'tcp://0.0.0.0:3000'
set :puma_error_log,          "#{release_path}/log/puma.error.log"
set :puma_threads,            [ENV.fetch('SEARCHGOV_MIN_THREADS', SEARCHGOV_THREADS), SEARCHGOV_THREADS]
set :puma_workers,            ENV.fetch('SEARCHGOV_WORKERS') { 0 }
set :rails_env,               'production'
set :rbenv_type,              :user
set :repo_url,                'https://github.com/GSA/search-gov'
set :resque_environment_task, true
set :resque_extra_env,        "RAILS_ROOT=#{ENV['DEPLOYMENT_PATH']}current"
set :systemctl_user,          :system
set :user,                    ENV['SERVER_DEPLOYMENT_USER']
set :whenever_roles,          :cron
set :workers,                 { '*' => ENV.fetch('RESQUE_WORKERS_COUNT', '5').to_i }
set :resque_log_file,         "log/resque.log"
set :deploy_lock_token,       ENV.fetch('DEPLOY_LOCK_TOKEN', SecureRandom.uuid)
# Prevent concurrent git operations on the same host. Wait for 180 seconds if locked.
SSHKit.config.command_map[:git] = "/usr/bin/flock -w 180 /tmp/git.lock /usr/bin/git"
append :linked_dirs,  'log', 'tmp', 'node_modules', 'public'
append :linked_files, '.env', 'config/logindotgov.pem'

role :app,              JSON.parse(ENV.fetch('APP_SERVER_ADDRESSES', '[]')),    user: ENV['SERVER_DEPLOYMENT_USER']
role :cron,             JSON.parse(ENV.fetch('CRON_SERVER_ADDRESSES', '[]')),   user: ENV['SERVER_DEPLOYMENT_USER']
role :db,               JSON.parse(ENV.fetch('APP_SERVER_ADDRESSES', '[]')),    user: ENV['SERVER_DEPLOYMENT_USER']
role :resque_scheduler, JSON.parse(ENV.fetch('RESQUE_SERVER_ADDRESSES', '[]')), user: ENV['SERVER_DEPLOYMENT_USER']
role :resque_worker,    JSON.parse(ENV.fetch('RESQUE_SERVER_ADDRESSES', '[]')), user: ENV['SERVER_DEPLOYMENT_USER']
role :web,              JSON.parse(ENV.fetch('APP_SERVER_ADDRESSES', '[]')),    user: ENV['SERVER_DEPLOYMENT_USER']

set :ssh_options, {
  auth_methods:  %w(publickey),
  forward_agent: false,
  keys:          [ENV['SSH_KEY_PATH']],
  user:          ENV['SERVER_DEPLOYMENT_USER'],
}

namespace :deploy do
  desc 'Acquire per-host deploy lock to prevent concurrent Capistrano runs'
  task :acquire_host_lock do
    on roles(:all), in: :sequence, wait: 1 do
      lock_dir = "#{fetch(:deploy_to)}/.deploy_lock"
      token = fetch(:deploy_lock_token)

      execute :mkdir, '-p', fetch(:deploy_to)

      begin
        execute :mkdir, lock_dir
        execute :sh, '-c', "printf '%s' #{Shellwords.escape(token)} > #{lock_dir}/token"
        info "Acquired deploy lock at #{lock_dir}"
      rescue SSHKit::Command::Failed
        error "Deploy lock already exists at #{lock_dir}. Another deployment may be running."
        raise
      end
    end
  end

  desc 'Release per-host deploy lock when this run owns it'
  task :release_host_lock do
    on roles(:all), in: :sequence, wait: 1 do
      lock_dir = "#{fetch(:deploy_to)}/.deploy_lock"
      token = fetch(:deploy_lock_token)

      if test("[ -f #{lock_dir}/token ]")
        existing_token = capture(:cat, "#{lock_dir}/token").strip
        if existing_token == token
          execute :rm, '-rf', lock_dir
          info "Released deploy lock at #{lock_dir}"
        else
          info "Skip lock release at #{lock_dir} (lock not owned by this deployment)"
        end
      else
        info "Skip lock release at #{lock_dir} (no lock present)"
      end
    end
  end
end

before 'deploy:starting', 'deploy:acquire_host_lock'
after 'deploy:finished', 'deploy:release_host_lock'
after 'deploy:failed', 'deploy:release_host_lock'
