module ES
  INDEX_PREFIX = "#{Rails.env}-usasearch".freeze

  def self.client_reader
    @@client_reader ||= Elasticsearch::Client.new(log: Rails.env == 'development', host: reader_host)
  end

  def self.client_writers
    @@client_writers ||= writer_hosts.collect { |writer_host| Elasticsearch::Client.new(log: Rails.env == 'development', host: writer_host) }
  end

  private

  def self.reader_host
    yaml['reader']
  end

  def self.writer_hosts
    hosts = yaml['writers']
    hosts = [hosts] unless hosts.is_a? Array
    hosts
  end

  def self.yaml
    @@yaml ||= YAML.load_file("#{Rails.root}/config/elasticsearch.yml")
  end
end
