set :user,        "search"
set :deploy_to,   "/home/jwynne/#{application}"
set :domain,      "173.203.40.160"
set :branch,      "rackspace"
server domain, :app, :web, :db, :primary => true
