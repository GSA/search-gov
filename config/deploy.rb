set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "usasearch"
set :scm,         "git"
set :repository,  "git@github.com:loren/#{application}.git"
set :use_sudo,    false

after :deploy, 'deploy:cleanup'
after "deploy:finalize_update", "deploy:migrate"

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

before "deploy:symlink", "install_gems"
before "deploy:symlink", "fix_permissions"

desc "Installs gems as specified in environment.rb"
task :install_gems do
  rake = fetch(:rake, 'rake')
  rails_env = fetch(:rails_env, 'production')
  run "cd #{release_path}; sudo #{rake} RAILS_ENV=#{rails_env} gems:install"
end

desc "Make releases directory readable/writable (+rx) to workaround overly restrictive default umask"
task :fix_permissions do
  run "cd #{release_path}; sudo chmod -R a+rx ."
end