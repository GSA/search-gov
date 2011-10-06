require 'bundler/capistrano'

set :stages, %w(staging production labs)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "usasearch"
set :scm,         "git"
set :repository,  "git@github.com:GSA-OCSIT/#{application}.git"
set :use_sudo,    false
set :deploy_via, :remote_cache

before "deploy:restart", "deploy:maybe_migrate"
before "deploy:symlink", "deploy:web:disable"
after :deploy, "deploy:web:enable"
after :deploy, 'deploy:cleanup'

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Only migrate if 'migrate' param is passed in via '-S migrate=true'"
  task :maybe_migrate, :roles => :db, :only => {:primary => true} do
    find_and_execute_task("deploy:migrate") if exists?(:migrate)
  end
end

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require './config/boot'
require 'hoptoad_notifier/capistrano'
