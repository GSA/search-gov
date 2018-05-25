require 'typhoeus/adapters/faraday'

module ES
  INDEX_PREFIX = "#{Rails.env}-usasearch".freeze

  def client_reader
    @client_reader ||= Elasticsearch::Client.new(log: Rails.env == 'development', host: reader_host)
  end

  def client_writers
    @client_writers ||= writer_hosts.collect do |writer_host|
      Elasticsearch::Client.new(log: Rails.env == 'development', host: writer_host)
    end
  end

  private

  def reader_host
    Rails.application.secrets.elasticsearch['reader'][self.client_config]
  end

  def writer_hosts
    Rails.application.secrets.elasticsearch['writers'][self.client_config]
  end

  module ELK
    extend ES
    private

    def self.client_config
      'analytics'
    end
  end

  module CustomIndices
    extend ES
    private

    def self.client_config
      'custom_search'
    end
  end
end
