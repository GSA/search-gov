require 'yaml'
require 'airbrake'

rails_root = Rails.root || File.join(File.dirname(__FILE__), '../..')
rails_env  = Rails.env || 'development'
options    = YAML.load(ERB.new(File.read(File.join(rails_root, 'config/airbrake.yml'))).result)[rails_env]
enabled    = !!options['enabled']

if enabled
  Airbrake.configure do |config|
    config.api_key = options['api_key'] || raise("No AirBrake API key provided!")
    config.secure  = !!options['secure']
    (options['ignore'] || []).each { |i| config.ignore << i }
  end
end
