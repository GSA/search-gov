set :user,        "search"
set :deploy_to,   "/home/search/#{application}"
set :branch,      fetch(:branch, "master")
set :domain,      "192.168.100.169"
server domain,    :app, :web, :db, :primary => true
role :daemon,     "192.168.100.169"

set :system_yml_filenames, %w(
  airbrake asset_configuration aws external_faraday hosted_azure jwt mandrill nutshell
  sc_access_key
)

after 'deploy:finalize_update', 'staging_specific_files'
before "deploy:cleanup", "restart_resque_workers"
after :deploy, "warmup"

task :staging_specific_files, roles: :app do
  run "cp #{shared_path}/system/??.yml #{shared_path}/system/???.yml #{release_path}/config/locales/"
  run "cp #{shared_path}/system/system_name.txt #{release_path}/config/"
end

task :restart_resque_workers, :roles => :web do
  run "cp #{shared_path}/system/throttled_rss_feed_hosts.yml #{release_path}/config/throttled_rss_feed_hosts.yml"
  run "cp #{shared_path}/system/url_status_code_fetcher.yml #{release_path}/config/url_status_code_fetcher.yml"
  run "/home/search/scripts/stop_resque_workers"
  run "/home/search/scripts/start_resque_workers"
end

task :warmup, :roles => :web do
  run "wget --delete-after --user=demo --password=***REMOVED*** http://searchdemo.usa.gov/search?affiliate=usagov&query=government"
end
