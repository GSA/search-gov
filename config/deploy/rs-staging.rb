set :user,        "search"
set :deploy_to,   "/home/jwynne/#{application}"
set :domain,      "192.168.100.160"
set :branch,      "rackspace"
server domain, :app, :web, :db, :primary => true
