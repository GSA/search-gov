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

# Keep only the last 5 releases to save disk space
set :keep_releases, 5

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log, "#{release_path}/log/puma.error.log"
set :puma_threads, [0, 8]
set :puma_workers, 0
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_preload_app, false
set :puma_bind, "tcp://0.0.0.0:3000"
