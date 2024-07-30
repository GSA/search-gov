# config valid for current version and patch releases of Capistrano
lock '~> 3.19.1'

set :application, 'search-gov'
set :repo_url, 'https://github.com/GSA/search-gov'
set :branch, 'staging'

# Set the directory to deploy to
set :deploy_to, ENV['DEPLOYMENT_PATH']

# Use rbenv to manage Ruby versions
set :rbenv_type, :user
set :rbenv_ruby, '3.1.4'

# Linked files and directories (these will be shared across releases)
# set :linked_files, %w{
#   config/database.yml
# }

set :optional_linked_files, %w{
  config/secrets.yml
}

set :linked_dirs, %w{
  log
  tmp
}
