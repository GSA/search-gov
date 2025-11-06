# frozen_string_literal: true

require 'elasticsearch'

# NOTE: This uses the Elasticsearch::Client because the opensearch-ruby gem
# has a dependency on a newer version of faraday than is allowed by the
# omniauth_login_dot_gov gem.
#
# The elasticsearch-ruby gem is API-compatible with OpenSearch 1.x and 2.x.
#
# This client is used for analytics data (logstash indices) when the
# OPENSEARCH_ANALYTICS_ENABLED feature flag is set to 'true'.
if ENV['OPENSEARCH_ANALYTICS_ENABLED'] == 'true'
  OPENSEARCH_ANALYTICS_CLIENT_CONFIG = Rails.application.config_for(
    :opensearch_analytics_client
  ).deep_symbolize_keys.freeze

  OPENSEARCH_ANALYTICS_CLIENT = Elasticsearch::Client.new(
    OPENSEARCH_ANALYTICS_CLIENT_CONFIG
  ).tap do |client|
    client.transport.logger = Rails.logger.clone
    client.transport.logger.formatter = proc do |severity, time, _progname, msg|
      "\e[2m[OPENSEARCH_ANALYTICS][#{time.utc.iso8601(4)}][#{severity}] #{msg}\n\e[0m"
    end
  end
end
