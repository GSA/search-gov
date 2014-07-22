require 'instagram'

yaml = YAML.load_file("#{Rails.root}/config/instagram.yml")

Instagram.configure do |config|
  config.client_id = yaml['client_id']
  config.client_secret = yaml['client_secret']
end

INSTAGRAM_ACCESS_TOKEN = yaml['access_token']
