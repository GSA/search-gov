set :user,        "search"
set :deploy_to,   "/home/jwynne/#{application}-rails3"
set :domain,      "192.168.100.160"
set :branch,      "rails3"
server domain, :app, :web, :db, :primary => true
