set :stages, %w(staging production labs)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "usasearch"
set :scm,         "git"
set :repository,  "git@github.com:GSA-OCSIT/#{application}.git"
set :use_sudo,    false

before "deploy:restart", "deploy:migrate"
before :deploy, "deploy:web:disable"
after :deploy, "deploy:web:enable"
after :deploy, 'deploy:cleanup'

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

before "deploy:symlink", "install_gems"

desc "Installs gems as specified in environment.rb"
task :install_gems do
  rake = fetch(:rake, 'rake')
  rails_env = fetch(:rails_env, 'production')
  run "cd #{release_path}; sudo #{rake} RAILS_ENV=#{rails_env} gems:install"
end

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
