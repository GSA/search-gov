set :user,        "search"
set :deploy_to,   "/home/jwynne/#{application}"
set :branch,      "rackspace"
role :app, "192.168.100.164", "192.168.100.165", "192.168.100.166", "192.168.110.10", "192.168.100.161", "192.168.110.11"
role :web, "192.168.100.164", "192.168.100.165", "192.168.100.166", "192.168.110.10", "192.168.100.161", "192.168.110.11"
role :db,  "192.168.100.161", :primary => true

before "deploy:symlink", "production_yaml_files"

task :production_yaml_files, :except => { :no_release => true } do
  run "cp #{shared_path}/system/database.yml #{release_path}/config/database.yml"
  run "cp #{shared_path}/system/sunspot.yml #{release_path}/config/sunspot.yml"
end
