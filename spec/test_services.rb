# frozen_string_literal: true

module TestServices
  extend self

  def create_es_indexes
    Dir[Rails.root.join('app/models/elastic_*.rb').to_s].each do |filename|
      klass = File.basename(filename, '.rb').camelize.constantize
      # Each model uses its own client (Elasticsearch or OpenSearch) based on use_opensearch?
      klass.recreate_index if klass.is_a?(Indexable) && klass != ElasticBlended
    end
    logstash_index_range.each do |date|
      # Always create logstash indices in Elasticsearch (needed for X-Pack Watcher)
      create_elasticsearch_logstash_index(date)
      # Also create in OpenSearch when enabled (needed for analytics queries)
      create_opensearch_logstash_index(date) if opensearch_enabled?
    end
  end

  def delete_es_indexes
    # Delete Elasticsearch indices
    Es::CustomIndices.client_reader.indices.delete(index: 'test-usasearch-*')
    # Delete OpenSearch indices if enabled
    if opensearch_enabled? && defined?(OPENSEARCH_CLIENT)
      OPENSEARCH_CLIENT.indices.delete(index: 'test-usasearch-*', ignore_unavailable: true)
    end
    logstash_index_range.each do |date|
      # Always delete from Elasticsearch
      delete_elasticsearch_logstash_index(date)
      # Also delete from OpenSearch when enabled
      delete_opensearch_logstash_index(date) if opensearch_enabled?
    end
  rescue StandardError => e
    Rails.logger.error 'Error deleting es indices:', e
  end

  def logstash_index_range
    end_date = Date.current
    start_date = end_date - 10.days
    start_date..end_date
  end

  def verify_xpack_license
    # Skip X-Pack license check when using OpenSearch
    return if opensearch_enabled?

    # An active trial license is required for the Watcher specs to pass.
    license = Es::ELK.client_reader.xpack.license.get['license']
    active_trial_license = (license['type'] == 'trial' && license['status'] == 'active')
    return if active_trial_license

    message = <<~MESSAGE
      You do not have an active Elasticsearch X-Pack trial license.
      Refer to https://github.com/GSA/search-services/wiki/Docker-Command-Reference#recreate-an-elasticsearch-cluster
    MESSAGE
    abort(message.red)
  end

  private

  def opensearch_enabled?
    OpenSearchConfig.enabled?
  end

  def create_opensearch_logstash_index(date)
    return unless defined?(OPENSEARCH_ANALYTICS_CLIENT)

    index_name = "logstash-#{date.strftime('%Y.%m.%d')}"
    alias_name = "human-logstash-#{date.strftime('%Y.%m.%d')}"

    OPENSEARCH_ANALYTICS_CLIENT.indices.delete(
      index: index_name,
      ignore_unavailable: true
    )
    OPENSEARCH_ANALYTICS_CLIENT.indices.create(index: index_name)
    OPENSEARCH_ANALYTICS_CLIENT.indices.put_alias(
      index: index_name,
      name: alias_name
    )
  end

  def create_elasticsearch_logstash_index(date)
    index_name = "logstash-#{date.strftime('%Y.%m.%d')}"
    alias_name = "human-logstash-#{date.strftime('%Y.%m.%d')}"

    # Use elasticsearch_client directly (not client_reader which may return OpenSearch)
    Es::ELK.elasticsearch_client.indices.delete(
      index: index_name,
      ignore_unavailable: true
    )
    Es::ELK.elasticsearch_client.indices.create(index: index_name)
    Es::ELK.elasticsearch_client.indices.put_alias(
      index: index_name,
      name: alias_name
    )
  end

  def delete_opensearch_logstash_index(date)
    return unless defined?(OPENSEARCH_ANALYTICS_CLIENT)

    OPENSEARCH_ANALYTICS_CLIENT.indices.delete(
      index: "logstash-#{date.strftime('%Y.%m.%d')}"
    )
  end

  def delete_elasticsearch_logstash_index(date)
    Es::ELK.elasticsearch_client.indices.delete(
      index: "logstash-#{date.strftime('%Y.%m.%d')}",
      ignore_unavailable: true
    )
  end
end
