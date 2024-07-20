# config/deploy/staging.rb

# Server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

server ENV['SERVER_ADDRESS'], user: ENV['SERVER_DEPLOYMENT_USER'], roles: %w{app db web}

# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb.
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customize your setup.

set :rails_env, 'production'
set :aws_ssm_path, ENV['AWS_SSM_PATH']
set :bundle_without, %w{development test}.join(' ')


# Fetch and set environment variables
fetch(:default_env).merge!(
  'SECRET_KEY_BASE' => '1',
  'SKIP_CSS_BUILD' => '1'
)

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a limited set of options, consult the Net/SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start

# Global options
# --------------
set :ssh_options, {
  keys: [ENV['SSH_KEY_PATH']],
  forward_agent: false,
  auth_methods: %w(publickey)
}

# The server-based syntax can be used to override options:
# ------------------------------------
# server "staging.server.com",
#   user: "deploy",
#   roles: %w{web app},
#   ssh_options: {
#     user: "deploy", # overrides user setting above
#     keys: [fetch(:ssh_key_path, '/default/path/to/staging_ec2_keypair.pem')],
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
