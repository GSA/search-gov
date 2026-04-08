# frozen_string_literal: true

require 'typhoeus/adapters/faraday'
require_relative 'opensearch_config'

module Es
  INDEX_PREFIX = "#{Rails.env}-usasearch".freeze

  CLIENT_CONFIG = Rails.application.config_for(
    :elasticsearch_client
  ).deep_symbolize_keys.freeze

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

    def self.client_reader
      if OpenSearchConfig.enabled?
        OpenSearchConfig.analytics_client
      else
        @client_reader ||= initialize_client
      end
    end

    def self.client_writers
      if OpenSearchConfig.enabled?
        @open_search_client_writers ||= [OpenSearchConfig.analytics_client]
      else
        @client_writers ||= [initialize_client]
      end
    end

    # Returns the Elasticsearch client directly, bypassing OpenSearch.
    # Used for Elasticsearch-specific features like X-Pack Watcher.
    def self.elasticsearch_client
      @elasticsearch_client ||= initialize_client
    end
  end

  # CustomIndices always uses Elasticsearch (for deprecated custom indices)
  # OpenSearch-migrated indices (like ElasticBoostedContent) use their own client
  module CustomIndices
    extend Es

    def self.client_reader
      @client_reader ||= initialize_client
    end

    def self.client_writers
      @client_writers ||= [initialize_client]
    end
  end
end
