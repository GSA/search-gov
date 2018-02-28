module TwitterClient
  def self.instance
    @@client ||= begin
      Twitter::REST::Client.new do |config|
        Rails.application.secrets.twitter.each do |key, value|
          config.send("#{key}=", value)
        end
      end
    end
  end
end
