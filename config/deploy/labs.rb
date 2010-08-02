set :user,        "labs"
set :deploy_to,   "/home/labs/#{application}"
set :domain,      "184.72.238.88"
server domain, :app, :web, :db, :primary => true
set :branch, "labs"
set :rails_env, "labs"