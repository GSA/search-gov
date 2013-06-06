require 'bundler/capistrano'

set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
require 'new_relic/recipes'

set :application, "usasearch"
set :scm,         "git"
set :repository,  "git@github.com:GSA-OCSIT/#{application}.git"
set :use_sudo,    false
set :deploy_via, :remote_cache

before "deploy:restart", "deploy:maybe_migrate"
before 'deploy:create_symlink', 'deploy:web:disable'
before 'deploy:create_symlink', 'deploy:symlink_cache'
before 'deploy:create_symlink', 'deploy:create_sayt_symlink'
after 'deploy:restart', 'deploy:web:enable'
after 'deploy:restart', 'deploy:cleanup'
before "deploy:cleanup", "deploy:restart_rake_tasks"
after "deploy:update", "newrelic:notice_deployment"

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Only migrate if 'migrate' param is passed in via '-S migrate=true'"
  task :maybe_migrate, :roles => :db, :only => {:primary => true} do
    find_and_execute_task("deploy:migrate") if exists?(:migrate)
  end

  desc "Create symlink for tmp/cache"
  task :symlink_cache, :roles => :app do
    run "ln -s #{shared_path}/cache #{release_path}/tmp/cache"
  end

  desc 'Restart daemon rake tasks'
  task :restart_rake_tasks, :roles => :daemon do
    run "/home/search/scripts/stop_rake_tasks"
    run "/home/search/scripts/start_rake_tasks"
  end

  desc 'Create symlink for static resources'
  task :create_sayt_symlink, :roles => :web do
    run "ln -s #{shared_path}/assets/sayt_loader.js #{release_path}/public/javascripts/remote.loader.js"
    run "ln -s #{shared_path}/assets/sayt_loader.js #{release_path}/public/javascripts/sayt/remote.js"
  end
end

require './config/boot'
require 'airbrake/capistrano'
