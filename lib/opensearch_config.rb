# frozen_string_literal: true

# Configuration module for OpenSearch feature flag
# Caches the OPENSEARCH_APP_ENABLED environment variable to avoid repeated lookups
module OpenSearchConfig
  def self.enabled?
    @enabled ||= ENV['OPENSEARCH_APP_ENABLED']&.downcase == 'true'
  end

  # Reset the cached value (useful for testing)
  def self.reset!
    @enabled = nil
  end

  # Returns the OpenSearch analytics client or raises an error if not initialized
  def self.analytics_client
    unless defined?(OPENSEARCH_ANALYTICS_CLIENT)
      raise "OPENSEARCH_ANALYTICS_CLIENT is not initialized."
    end
    OPENSEARCH_ANALYTICS_CLIENT
  end

  # Returns the OpenSearch search client or raises an error if not initialized
  def self.search_client
    unless defined?(OPENSEARCH_CLIENT)
      raise "OPENSEARCH_CLIENT is not initialized."
    end
    OPENSEARCH_CLIENT
  end
end
