set :user,        "search"
set :deploy_to,   "/home/search/#{application}"
set :domain,      "192.168.100.169"
server domain, :app, :web, :db, :primary => true
role :daemon, "192.168.100.169"

before "deploy:create_symlink", "staging_yaml_files"
before "deploy:cleanup", "restart_resque_workers"
after :deploy, "warmup"

task :staging_yaml_files, roles: :app do
  run "cp #{shared_path}/system/usajobs.yml #{release_path}/config/usajobs.yml"
end

task :restart_resque_workers, :roles => :web do
  run "cp #{shared_path}/system/throttled_rss_feed_hosts.yml #{release_path}/config/throttled_rss_feed_hosts.yml"
  run "cp #{shared_path}/system/url_status_code_fetcher.yml #{release_path}/config/url_status_code_fetcher.yml"
  run "/home/search/scripts/stop_resque_workers"
  run "/home/search/scripts/start_resque_workers"
end

task :warmup, :roles => :web do
  run "wget --delete-after --user=demo --password=***REMOVED*** http://searchdemo.usa.gov"
end
