module ES
  INDEX_PREFIX = "#{Rails.env}:usasearch".freeze

  def self.client
    es_config = YAML.load_file("#{Rails.root}/config/elasticsearch.yml")
    @@client ||= Elasticsearch::Client.new(log: Rails.env == 'development', host: es_config['host'])
  end
end
