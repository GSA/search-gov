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
before "deploy:restart", "deploy:compass_compile"
before "deploy:symlink", "deploy:web:disable"
before "deploy:symlink", "deploy:symlink_cache"
after :deploy, "deploy:web:enable"
after :deploy, 'deploy:cleanup'
before "deploy:cleanup", "deploy:restart_twitter_tasks"
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

  desc "Run 'compass compile' to build the stylesheets"
  task :compass_compile, :roles => :app do
    run "cd #{current_path} ; bundle exec compass compile --output-style compressed"
  end

  desc "Create symlink for tmp/cache"
  task :symlink_cache, :roles => :app do
    run "ln -s #{shared_path}/cache #{release_path}/tmp/cache"
  end

  task :restart_twitter_tasks, :roles => :twitter do
    run "/home/search/scripts/stop_twitter_tasks"
    run "/home/search/scripts/start_twitter_tasks"
  end
end

require './config/boot'
require 'airbrake/capistrano'
