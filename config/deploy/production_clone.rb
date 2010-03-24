set :user,        "web"
set :deploy_to,   "/var/www/#{application}"
set :branch, "production"
role :app, "10.153.9.213", "10.153.9.214"
role :web, "10.153.9.213", "10.153.9.214"
role :db,  "10.153.9.213", :primary => true

before "deploy:symlink", "production_yaml_files"
after "deploy:migrate", "freshen_data"

task :production_yaml_files, :except => { :no_release => true } do
  run "cp #{shared_path}/system/database.yml #{release_path}/config/database.yml"
  run "cp #{shared_path}/system/sunspot.yml #{release_path}/config/sunspot.yml"
end

task :freshen_data, :roles => :db do
  # don't copy over sessions, and do large tables individually otherwise the whole thing times out
  # read from slave2 since slave1's disks are 70x slower
  run "/usr/bin/mysqldump --defaults-file=/var/www/.my.cnf --opt --ignore-table=usasearch_production.sessions --ignore-table=usasearch_production.daily_query_stats -h10.153.8.233 usasearch_production | /usr/bin/mysql --defaults-file=/var/www/.my.cnf -h10.153.8.236 usasearch_production"
  run "/usr/bin/mysqldump --defaults-file=/var/www/.my.cnf --opt -h10.153.8.233 usasearch_production daily_query_stats | /usr/bin/mysql --defaults-file=/var/www/.my.cnf -h10.153.8.236 usasearch_production"  
  run "cd #{release_path} && /usr/local/bin/rake sunspot:solr:reindex RAILS_ENV=production"
end
