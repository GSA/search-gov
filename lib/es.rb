require 'typhoeus/adapters/faraday'

module ES
  INDEX_PREFIX = "#{Rails.env}-usasearch".freeze

  def self.client_reader
    @@client_reader ||= Elasticsearch::Client.new(log: Rails.env == 'development', host: reader_host)
  end

  def self.client_writers
    @@client_writers ||= writer_hosts.collect do |writer_host|
      Elasticsearch::Client.new(log: Rails.env == 'development', host: writer_host)
    end
  end

  private

  def self.reader_host
    Rails.application.secrets.elasticsearch['reader']
  end

  def self.writer_hosts
    Rails.application.secrets.elasticsearch['writers']
  end
end
