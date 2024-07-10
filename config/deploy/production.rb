# config/deploy/production.rb

# Server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

server "production.server.com", user: "deploy", roles: %w{app db web}

# Role-based syntax
# ==================
# Defines a role with one or multiple servers.
# The primary server in each group is considered to be the first unless any hosts have the primary property set.
# Specify the username and a domain or IP for the server.

# role :app, %w{deploy@production.server.com}
# role :web, %w{user1@production.server.com user2@production.server.com}
# role :db,  %w{deploy@production.server.com}

# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb.
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customize your setup.

set :rails_env, 'production'
set :aws_ssm_path, '/your/application/env/production/'

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start

# Global options
# --------------
# set :ssh_options, {
#   keys: %w(/home/deploy/.ssh/id_rsa),
#   forward_agent: false,
#   auth_methods: %w(publickey)
# }

# The server-based syntax can be used to override options:
# ------------------------------------
# server "production.server.com",
#   user: "deploy",
#   roles: %w{web app},
#   ssh_options: {
#     user: "deploy", # overrides user setting above
#     keys: %w(/home/deploy/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
