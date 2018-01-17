module Tika
  # wrapper methods for https://wiki.apache.org/tika/TikaJAXRS

  def self.get_recursive_metadata(file)
    # The recursive metadata request is designed for embedded files and compressed files,
    # but we're using it as it is the only method that extracts both metadata and content
    # at once.
    response = client.post('/rmeta/form/text',
                           form: { upload: HTTP::FormData::File.new(file.path) })
    raise TikaError.new("Parsing failure: #{response.status}") unless response.status == 200
    JSON.parse(response)
  end

  def self.host
    yaml['host']
  end

  def self.port
    yaml['port']
  end

  def self.yaml
    @@yaml ||= YAML.load_file("#{Rails.root}/config/tika.yml")[Rails.env]
  end

  def self.client
    @tika_client ||= HTTP.persistent "http://#{host}:#{port}"
  end

  private_class_method :host, :port, :yaml, :client
end

class TikaError < StandardError; end
