# frozen_string_literal: true

# Accessors for the OpenSearch clients and related runtime flags.
module OpenSearchConfig
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

  # Global kill switch for Rails crawler writes to LEGACY_OPENSEARCH_INDEX.
  # Writes are enabled by default; only an explicit false (case-insensitive) disables them.
  def self.crawler_index_writes_enabled?
    !ENV['OPENSEARCH_CRAWLER_INDEX_WRITES_ENABLED'].to_s.strip.casecmp?('false')
  end

  def self.crawler_index_writes_disabled?
    !crawler_index_writes_enabled?
  end
end
