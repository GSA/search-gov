# frozen_string_literal: true

module TestServices
  extend self

  def create_es_indexes
    Dir[Rails.root.join('app/models/elastic_*.rb').to_s].each do |filename|
      klass = File.basename(filename, '.rb').camelize.constantize
      klass.recreate_index if klass.is_a?(Indexable) && klass != ElasticBlended
    end
    logstash_index_range.each do |date|
      create_opensearch_logstash_index(date)
    end
  end

  def delete_es_indexes
    if defined?(OPENSEARCH_CLIENT)
      OPENSEARCH_CLIENT.indices.delete(index: 'test-usasearch-*', ignore_unavailable: true)
    end
    logstash_index_range.each do |date|
      delete_opensearch_logstash_index(date)
    end
  rescue StandardError => e
    Rails.logger.error 'Error deleting OpenSearch indices:', e
  end

  def logstash_index_range
    end_date = Date.current
    start_date = end_date - 10.days
    start_date..end_date
  end

  private

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

  def delete_opensearch_logstash_index(date)
    return unless defined?(OPENSEARCH_ANALYTICS_CLIENT)

    OPENSEARCH_ANALYTICS_CLIENT.indices.delete(
      index: "logstash-#{date.strftime('%Y.%m.%d')}",
      ignore_unavailable: true
    )
  end
end
