set :user,        "search"
set :deploy_to,   "/home/jwynne/#{application}"
set :branch,      "production"
role :app, "192.168.100.164", "192.168.100.165", "192.168.100.166", "192.168.110.10", "192.168.100.161", "192.168.110.11"
role :web, "192.168.100.164", "192.168.100.165", "192.168.100.166", "192.168.110.10", "192.168.100.161", "192.168.110.11"
role :db,  "192.168.100.161", :primary => true
role :resque_workers,  "192.168.100.164", "192.168.100.165", "192.168.100.166"

before "deploy:symlink", "production_yaml_files"
before "deploy:cleanup", "restart_resque_workers"

task :restart_resque_workers, :roles => :resque_workers do
  run "sudo /home/jwynne/scripts/stop_resque_workers"
  run "sudo /home/jwynne/scripts/start_resque_workers"
end

task :production_yaml_files, :except => { :no_release => true } do
  run "cp #{shared_path}/system/database.yml #{release_path}/config/database.yml"
  run "cp #{shared_path}/system/sunspot.yml #{release_path}/config/sunspot.yml"
  run "cp #{shared_path}/system/redis.yml #{release_path}/config/redis.yml"
  run "cp #{shared_path}/system/faq.yml #{release_path}/config/faq.yml"
end