# frozen_string_literal: true

require 'typhoeus/adapters/faraday'
require_relative 'opensearch_config'

module Es
  INDEX_PREFIX = "#{Rails.env}-usasearch".freeze

  # Analytics data (logstash indices) is served by OpenSearch.
  module ELK
    def self.client_reader
      OpenSearchConfig.analytics_client
    end

    def self.client_writers
      [OpenSearchConfig.analytics_client]
    end
  end
end
