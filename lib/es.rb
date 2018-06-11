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
    self.client_config 'reader'
  end

  def writer_hosts
    self.client_config 'writers'
  end

  module ELK
    extend ES
    private

    def self.client_config(mode)
      Rails.application.secrets['analytics']['elasticsearch'][mode]
    end
  end

  module CustomIndices
    extend ES
    private

    def self.client_config(mode)
      Rails.application.secrets['custom_indices']['elasticsearch'][mode]
    end
  end
end
