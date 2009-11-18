set :user,        "xcet_admin"
set :deploy_to,   "/home/xcet_admin/#{application}"
set :domain,      "209.251.180.31"
server domain, :app, :web, :db, :primary => true
