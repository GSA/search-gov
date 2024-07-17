# config valid for current version and patch releases of Capistrano
lock '~> 3.19.1'

set :application, 'search-gov'
set :repo_url, 'https://github.com/GSA/search-gov'
set :branch, 'main'

# Set the directory to deploy to
set :deploy_to, ENV['DEPLOYMENT_PATH']
set :releases_directory, File.join(ENV['DEPLOYMENT_PATH'], 'releases')
set :current_directory, File.join(ENV['DEPLOYMENT_PATH'], 'current')
set :bundle_without, %w{development test}.join(' ')

# Use rbenv to manage Ruby versions
set :rbenv_type, :user
set :rbenv_ruby, '3.1.4'

# Linked files and directories (these will be shared across releases)
append :linked_files, '.env'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'vendor', 'storage', '.bundle', 'public/assets'

# Keep only the last 5 releases to save disk space
set :keep_releases, 5

namespace :deploy do

  task :fetch_env_vars do
    on roles(:app) do
      within release_path do
        info "Fetching environment variables from AWS SSM..."
        require 'aws-sdk-ssm'
        require 'fileutils'

        client = Aws::SSM::Client.new(region: ENV['AWS_REGION'])
        path = ENV['AWS_SSM_PATH']
        env_vars = client.get_parameters_by_path({
                                                   path: path,
                                                   with_decryption: true
                                                 }).parameters

        # parse env_vars
        # and set to default_envs using
        # the following pattern:
        # source: https://capistranorb.com/documentation/getting-started/configuration/
        #  fetch(:default_env).merge!(
        #    'SECRET_KEY_BASE' => '1'
        #  )
      end
    end
  end


  task :use_node_version do
    on roles(:app) do
      within release_path do
        execute 'source ~/.nvm/nvm.sh && nvm install 16.20.2'
        execute 'source ~/.nvm/nvm.sh && nvm use 16.20.2'
      end
    end
  end

  task :ensure_yarn do
    on roles(:app) do
      within release_path do
        execute 'source ~/.nvm/nvm.sh && yarn install'
      end
    end
  end

  task :precompile_assets do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env), SECRET_KEY_BASE: '1', SKIP_CSS_BUILD: '1' do
          execute :rake, 'assets:precompile'
        end
      end
    end
  end

  before 'deploy:assets:precompile', 'deploy:use_node_version'
  before 'deploy:assets:precompile', 'deploy:ensure_yarn'
  before 'deploy:assets:precompile', 'deploy:precompile_assets'

  after :finishing, 'deploy:cleanup'
  after :finishing, 'deploy:restart'
  after :rollback, 'deploy:restart'
end



