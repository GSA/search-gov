# frozen_string_literal: true

require 'typhoeus/adapters/faraday'

module Es
  INDEX_PREFIX = "#{Rails.env}-usasearch"

  CLIENT_CONFIG = Rails.application.config_for(
    :elasticsearch_client
  ).deep_symbolize_keys.freeze

  def client_reader
    @client_reader ||= initialize_client
  end

  def client_writers
    @client_writers ||= [initialize_client]
  end

  private

  def initialize_client(config = {})
    Elasticsearch::Client.new(config.merge(CLIENT_CONFIG)).tap do |client|
      client.transport.logger = Rails.logger.clone
      client.transport.logger.formatter = proc do |severity, time, _progname, msg|
        "\e[2m[ES][#{time.utc.iso8601(4)}][#{severity}] #{msg}\n\e[0m"
      end
    end
  end

  module ELK
    extend Es
  end

  module CustomIndices
    extend Es
  end
end
