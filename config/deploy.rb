# config valid for current version and patch releases of Capistrano
lock '~> 3.19.1'

set :application, 'search-gov'
set :repo_url, 'https://github.com/GSA/search-gov'
set :branch, 'main'

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

# Keep only the last 5 releases to save disk space
set :keep_releases, 5

# Configurations for Capistrano and Puma
set :puma_threads, [4, 16]
set :puma_workers, 0

set :puma_bind, "tcp://0.0.0.0:3000" # or "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log, "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

namespace :deploy do
  task :skip_assets_precompile do
    on roles(:app) do
      info "Skipping assets precompile step"
    end
  end

  task :ensure_precompiled_assets do
    on roles(:app) do
      within release_path do
        unless test("[ -d #{release_path}/app/assets/builds ]")
          exit 1
        end
      end
    end
  end

  before 'deploy:symlink:release', 'deploy:skip_assets_precompile'
  before 'deploy:symlink:release', 'deploy:ensure_precompiled_assets'

  after :finishing, 'deploy:cleanup'
  after :finishing, 'puma:restart'
  after :rollback, 'puma:restart'
end



