set :user,        "xcet_admin"
set :deploy_to,   "/home/xcet_admin/#{application}"
set :domain,      "10.153.9.201"
server domain, :app, :web, :db, :primary => true
