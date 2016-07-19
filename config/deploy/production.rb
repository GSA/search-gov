set :user,        "search"
set :deploy_to,   "/home/search/#{application}"
set :branch,      "production"

set :system_yml_filenames, %w(
  airbrake asset_configuration aws database elasticsearch external_faraday hosted_azure
  i14y instagram jwt mandrill nutshell oasis redis sc_access_key youtube
)

role :app, "192.168.100.170", "192.168.100.171", "192.168.100.173", "192.168.110.8", "192.168.100.174"
role :web, "192.168.100.170", "192.168.100.171", "192.168.100.173", "192.168.110.8", "192.168.100.174"
role :db,  "192.168.100.173", :primary => true
role :resque_workers,  "192.168.100.170", "192.168.100.173", "192.168.100.174"
role :daemon, "192.168.100.170"

after 'deploy:finalize_update', 'production_specific_files'
before "deploy:cleanup", "restart_resque_workers"

task :restart_resque_workers, :roles => :resque_workers do
  run "cp #{shared_path}/system/throttled_rss_feed_hosts.yml #{release_path}/config/throttled_rss_feed_hosts.yml"
  run "cp #{shared_path}/system/url_status_code_fetcher.yml #{release_path}/config/url_status_code_fetcher.yml"
  run "/home/search/scripts/stop_resque_workers"
  run "/home/search/scripts/start_resque_workers"
end

task :production_specific_files, roles: :app do
  run "cp #{shared_path}/system/geoip.dat #{release_path}/db/geoip/geoip.dat"
  run "cp -r #{shared_path}/system/analysis #{release_path}/config/locales/"
  run "cp #{shared_path}/system/??.yml #{shared_path}/system/???.yml #{release_path}/config/locales/"
  run "cp #{shared_path}/system/keen.rb #{release_path}/config/initializers/keen.rb"
end
