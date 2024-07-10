# config valid for current version and patch releases of Capistrano
lock "~> 3.19.1"

set :application, 'search-gov'
set :repo_url, "https://github.com/GSA/search-gov"
set :branch, "main"

# Set the directory to deploy to
set :deploy_to, '/var/www/my_app_name'

# Use rbenv to manage Ruby versions
set :rbenv_type, :user
set :rbenv_ruby, '3.1.4'

# Linked files and directories (these will be shared across releases)
append :linked_files, 'config/database.yml', 'config/secrets.yml', '.env'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'vendor', 'storage'

# Keep only the last 5 releases to save disk space
set :keep_releases, 5

# Custom tasks for fetching environment variables from AWS SSM
namespace :deploy do
  task :fetch_env_vars do
    on roles(:app) do
      within release_path do
        execute :bundle, :exec, :ruby, '-e', %Q{
          require 'aws-sdk-ssm'
          client = Aws::SSM::Client.new(region: 'us-east-1')
          path = fetch(:aws_ssm_path)
          env_vars = client.get_parameters_by_path({
            path: path,
            with_decryption: true
          }).parameters
          File.open('.env', 'w') do |file|
            env_vars.each do |param|
              file.puts "#{param.name.split('/').last}=#{param.value}"
            end
          end
        }
      end
    end
  end

  before 'deploy:check:linked_files', 'deploy:fetch_env_vars'

  after :finishing, 'deploy:cleanup'
  after :finishing, 'deploy:restart'
  after :rollback, 'deploy:restart'
  after :finishing, 'datadog:notify'
  after :rollback, 'datadog:notify'
end
