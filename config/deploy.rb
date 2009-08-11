#default_run_options[:pty] = true
set :application, "usasearch"
set :user,        "xcet_admin"
set :repository,  "git@github.com:loren/#{application}.git"
set :use_sudo,    false
set :deploy_to,   "/home/xcet_admin/#{application}"
set :scm,         "git"

after :deploy, 'deploy:cleanup'

role :web, "209.251.180.31"


namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

#before "deploy:symlink", "install_gems"
#
#desc "Installs gems as specified in environment.rb"
#task :install_gems do
#  rake = fetch(:rake, 'rake')
#  rails_env = fetch(:rails_env, 'production')
#  run "cd #{release_path}; sudo #{rake} RAILS_ENV=#{rails_env} gems:install"
#end