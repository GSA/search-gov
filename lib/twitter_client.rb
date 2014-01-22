module TwitterClient
  class << self
    attr_accessor :twitter_auth_env
  end

  self.twitter_auth_env = :default

  def self.instance
    @@client ||= begin
      Twitter::REST::Client.new do |config|
        twitter_config = YAML.load_file("#{Rails.root}/config/twitter.yml")
        twitter_auth = twitter_config[twitter_auth_env.to_s] || twitter_config['default']
        twitter_auth.each do |key, value|
          config.send("#{key}=", value)
        end
      end
    end
  end
end
