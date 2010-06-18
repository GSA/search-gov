set :user,        "xcet_admin"
set :deploy_to,   "/home/xcet_admin/#{application}_labs"
set :domain,      "10.153.9.201"
server domain, :app, :web, :db, :primary => true
set :branch, "labs"
set :rails_env, "labs"