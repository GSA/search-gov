set :user,        "web"
set :deploy_to,   "/var/www/#{application}"
role :app, "10.153.9.203", "10.153.9.211"
role :web, "10.153.9.203", "10.153.9.211"
role :db,  "10.153.9.203", :primary => true

before "deploy:symlink", "database_yaml"

task :database_yaml, :except => { :no_release => true } do
  run "cp #{shared_path}/system/database.yml #{release_path}/config/database.yml"
end
