set :user,        "web"
set :deploy_to,   "/var/www/#{application}"
role :app, "10.153.9.203", "10.153.9.211"
role :web, "10.153.9.203", "10.153.9.211"
role :db,  "10.153.9.203", :primary => true

before "deploy:symlink", "production_yaml_files"

task :production_yaml_files, :except => { :no_release => true } do
  run "cp #{shared_path}/system/database.yml #{release_path}/config/database.yml"
  run "cp #{shared_path}/system/sunspot.yml #{release_path}/config/sunspot.yml"
end
