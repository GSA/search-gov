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
    client_config(:reader)
  end

  def writer_config
    client_config(:writers)
  end

  def initialize_client(config)
    Elasticsearch::Client.new(config.merge(CLIENT_CONFIG)).tap do |client|
      client.transport.logger = logger
    end
  end

  def logger
    ActiveSupport::Logger.new("log/#{Rails.env}.log").tap do |logger|
      logger.level = CLIENT_CONFIG[:log_level]
      logger.formatter = proc do |severity, time, _progname, msg|
        "\e[2m[ES][#{time.utc.iso8601(4)}][#{severity}] #{msg}\n\e[0m"
      end
    end
  end

  module ELK
    extend Es
    private

    def self.client_config(mode)
      Rails.application.secrets[:analytics][:elasticsearch][mode].freeze
    end
  end

  module CustomIndices
    extend Es
    private

    def self.client_config(mode)
      Rails.application.secrets[:custom_indices][:elasticsearch][mode].freeze
    end
  end
end
