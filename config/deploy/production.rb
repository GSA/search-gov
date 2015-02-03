set :user,        "search"
set :deploy_to,   "/home/search/#{application}"
set :branch,      "production"
role :app, "192.168.100.170", "192.168.100.171", "192.168.100.173", "192.168.110.8", "192.168.100.174"
role :web, "192.168.100.170", "192.168.100.171", "192.168.100.173", "192.168.110.8", "192.168.100.174"
role :db,  "192.168.100.173", :primary => true
role :resque_workers,  "192.168.100.170", "192.168.100.173"
role :daemon, "192.168.100.170"

before 'deploy:assets:precompile', 'production_specific_files'
before "deploy:cleanup", "restart_resque_workers"

task :restart_resque_workers, :roles => :resque_workers do
  run "cp #{shared_path}/system/throttled_rss_feed_hosts.yml #{release_path}/config/throttled_rss_feed_hosts.yml"
  run "cp #{shared_path}/system/url_status_code_fetcher.yml #{release_path}/config/url_status_code_fetcher.yml"
  run "/home/search/scripts/stop_resque_workers"
  run "/home/search/scripts/start_resque_workers"
end

task :production_specific_files, :except => { :no_release => true } do
  run "cp #{shared_path}/system/database.yml #{release_path}/config/database.yml"
  run "cp #{shared_path}/system/redis.yml #{release_path}/config/redis.yml"
  run "cp #{shared_path}/system/geoip.dat #{release_path}/db/geoip/geoip.dat"
  run "cp -r #{shared_path}/system/analysis #{release_path}/config/locales/"
  run "cp #{shared_path}/system/keen.rb #{release_path}/config/initializers/keen.rb"
  run "cp #{shared_path}/system/elasticsearch.yml #{release_path}/config/elasticsearch.yml"
  run "cp #{shared_path}/system/oasis.yml #{release_path}/config/oasis.yml"
  run "cp #{shared_path}/system/instagram.yml #{release_path}/config/instagram.yml"
  run "cp #{shared_path}/system/nutshell.yml #{release_path}/config/nutshell.yml"
end
