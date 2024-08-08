# frozen_string_literal: true

require 'typhoeus/adapters/faraday'

module Es
  INDEX_PREFIX = "#{Rails.env}-usasearch"

  CLIENT_CONFIG = Rails.application.config_for(
    :elasticsearch_client
  ).deep_symbolize_keys.freeze

  def client_reader
    @client_reader ||= initialize_client(reader_config)
  end

  def client_writers
    @client_writers ||= writer_config.map { |config| initialize_client(config) }
  end

  private

  def reader_config
    client_config(:reader) || {}
  end

  def writer_config
    client_config(:writers) || [{}]
  end

  def initialize_client(config)
    Elasticsearch::Client.new(config.merge(CLIENT_CONFIG)).tap do |client|
      client.transport.logger = Rails.logger.clone
      client.transport.logger.formatter = proc do |severity, time, _progname, msg|
        "\e[2m[ES][#{time.utc.iso8601(4)}][#{severity}] #{msg}\n\e[0m"
      end
    end
  end

  module ELK
    extend Es

    private

    def self.client_config(mode)
      config = {
        hosts: ENV['ES_HOSTS'] ? JSON.parse(ENV['ES_HOSTS']) : Rails.application.secrets.dig(:analytics, :elasticsearch, mode, :hosts),
        user: ENV['ES_USER'] || Rails.application.secrets.dig(:analytics, :elasticsearch, mode, :user),
        password: ENV['ES_PASSWORD'] || Rails.application.secrets.dig(:analytics, :elasticsearch, mode, :password)
      }.compact

      config.freeze
    end
  end

  module CustomIndices
    extend Es

    private

    def self.client_config(mode)
      config = {
        hosts: ENV['ES_HOSTS'] ? JSON.parse(ENV['ES_HOSTS']) : Rails.application.secrets.dig(:custom_indices, :elasticsearch, mode, :hosts),
        user: ENV['ES_USER'] || Rails.application.secrets.dig(:custom_indices, :elasticsearch, mode, :user),
        password: ENV['ES_PASSWORD'] || Rails.application.secrets.dig(:custom_indices, :elasticsearch, mode, :password)
      }.compact

      config.freeze
    end
  end
end
