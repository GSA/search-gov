set :user,        "search"
set :deploy_to,   "/home/search/#{application}"
set :branch,      "production"
role :app, "192.168.100.170", "192.168.100.171", "192.168.100.173", "192.168.110.8", "192.168.100.174", "192.168.110.12"
role :web, "192.168.100.170", "192.168.100.171", "192.168.100.173", "192.168.110.8", "192.168.100.174", "192.168.110.12"
role :db,  "192.168.100.173", :primary => true
role :resque_workers,  "192.168.100.170", "192.168.100.173"
role :daemon, "192.168.100.170"
role :solr, "192.168.100.174", "192.168.110.12"

before 'deploy:assets:precompile', 'production_specific_files'
before 'deploy:create_symlink', 'production_solrconfig'
before "deploy:cleanup", "restart_resque_workers"

task :restart_resque_workers, :roles => :resque_workers do
  run "/home/search/scripts/stop_resque_workers"
  run "/home/search/scripts/start_resque_workers"
end

task :production_solrconfig, :roles => :solr, :except => { :no_release => true } do
  run "cp #{shared_path}/system/solrconfig.xml #{release_path}/solr/conf/solrconfig.xml"
end

task :production_specific_files, :except => { :no_release => true } do
  run "cp #{shared_path}/system/database.yml #{release_path}/config/database.yml"
  run "cp #{shared_path}/system/sunspot.yml #{release_path}/config/sunspot.yml"
  run "cp #{shared_path}/system/redis.yml #{release_path}/config/redis.yml"
  run "cp #{shared_path}/system/geoip.dat #{release_path}/db/geoip/geoip.dat"
  run "cp #{shared_path}/system/keen.rb #{release_path}/config/initializers/keen.rb"
  run "cp #{shared_path}/system/elasticsearch.yml #{release_path}/config/elasticsearch.yml"
end
