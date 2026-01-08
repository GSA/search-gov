# frozen_string_literal: true

require 'capistrano/setup'

require 'capistrano/deploy'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/rbenv'

require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

require 'stringio'
require 'capistrano/puma'

install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd

require 'capistrano-resque'
require 'whenever/capistrano'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
