module ES
  INDEX_PREFIX = "#{Rails.env}:usasearch".freeze

  def self.client
    @@client ||= Elasticsearch::Client.new(log: Rails.env == 'development')
  end
end
