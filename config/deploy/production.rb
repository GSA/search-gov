set :user,        "search"
set :deploy_to,   "/home/search/#{application}"
set :branch,      "production"
role :app, "192.168.100.170", "192.168.100.171", "192.168.100.173", "192.168.110.8", "192.168.100.174", "192.168.110.12"
role :web, "192.168.100.170", "192.168.100.171", "192.168.100.173", "192.168.110.8", "192.168.100.174", "192.168.110.12"
role :db,  "192.168.100.173", :primary => true
role :resque_workers,  "192.168.100.170", "192.168.100.173"
role :twitter, "192.168.100.170"
role :solr, "192.168.100.174", "192.168.110.12"

before "deploy:symlink", "production_yaml_files"
before "deploy:symlink", "production_solrconfig"
before "deploy:cleanup", "restart_resque_workers"
before "deploy:cleanup", "restart_twitter_stream"

task :restart_resque_workers, :roles => :resque_workers do
  run "/home/search/scripts/stop_resque_workers"
  run "/home/search/scripts/start_resque_workers"
end

task :restart_twitter_stream, :roles => :twitter do
  run "/home/search/scripts/stop_twitter_tasks"
  run "/home/search/scripts/start_twitter_tasks"
end

task :production_solrconfig, :roles => :solr, :except => { :no_release => true } do
  run "cp #{shared_path}/system/solrconfig.xml #{release_path}/solr/conf/solrconfig.xml"
end

task :production_yaml_files, :except => { :no_release => true } do
  run "cp #{shared_path}/system/database.yml #{release_path}/config/database.yml"
  run "cp #{shared_path}/system/sunspot.yml #{release_path}/config/sunspot.yml"
  run "cp #{shared_path}/system/redis.yml #{release_path}/config/redis.yml"
  run "cp #{shared_path}/system/geoip.dat #{release_path}/db/geoip/geoip.dat"
end