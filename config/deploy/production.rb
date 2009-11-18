set :user,        "web"
set :deploy_to,   "/var/www/#{application}"
role :app, "10.153.9.203", "10.153.9.211"
role :web, "10.153.9.203", "10.153.9.211"
role :db,  "10.153.9.203", :primary => true
