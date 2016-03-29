require 'yaml'

rails_root = Rails.root || File.join(File.dirname(__FILE__), '../..')
rails_env  = Rails.env || 'development'
options    = YAML.load(ERB.new(File.read(File.join(rails_root, 'config/apiv2.yml'))).result)[rails_env]

UsasearchRails3::Application.config.apiv2 = Hashie::Mash.new(options)
