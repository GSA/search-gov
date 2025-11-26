# frozen_string_literal: true

require 'elasticsearch'
require_relative '../../lib/opensearch_config'

# NOTE: This uses the Elasticsearch::Client because the opensearch-ruby gem
# has a dependency on a newer version of faraday than is allowed by the
# omniauth_login_dot_gov gem.
#
# The elasticsearch-ruby gem is API-compatible with OpenSearch

def create_opensearch_client(config_name, log_prefix)
  config = Rails.application.config_for(config_name).deep_symbolize_keys.freeze

  Elasticsearch::Client.new(config).tap do |client|
    client.transport.logger = Rails.logger.clone
    client.transport.logger.formatter = proc do |severity, time, _progname, msg|
      "\e[2m[#{log_prefix}][#{time.utc.iso8601(4)}][#{severity}] #{msg}\n\e[0m"
    end
  end
end

if OpenSearchConfig.enabled?
  # OpenSearch client for search indices (regular domains)
  OPENSEARCH_CLIENT = create_opensearch_client(:opensearch_client, 'OPENSEARCH')

  # OpenSearch client for analytics data (logstash indices)
  OPENSEARCH_ANALYTICS_CLIENT = create_opensearch_client(:opensearch_analytics_client, 'OPENSEARCH_ANALYTICS')
end
