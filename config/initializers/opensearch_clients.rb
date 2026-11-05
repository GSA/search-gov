# frozen_string_literal: true

require 'opensearch'
require_relative '../../lib/opensearch_config'

def create_opensearch_client(config_name, log_prefix)
  config = Rails.application.config_for(config_name).deep_symbolize_keys
  logger = Rails.logger.clone
  logger.formatter = proc do |severity, time, _progname, msg|
    "\e[2m[#{log_prefix}][#{time.utc.iso8601(4)}][#{severity}] #{msg}\n\e[0m"
  end

  OpenSearch::Client.new(config.merge(logger: logger).freeze)
end

OPENSEARCH_CLIENT = create_opensearch_client(:opensearch_client, 'OPENSEARCH')
OPENSEARCH_ANALYTICS_CLIENT = create_opensearch_client(:opensearch_analytics_client, 'OPENSEARCH_ANALYTICS')
