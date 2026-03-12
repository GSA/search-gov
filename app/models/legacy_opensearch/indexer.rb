# frozen_string_literal: true

class LegacyOpenSearch::Indexer
  @index_creator = SearchElastic::IndexCreate.new(
    service_name: 'LEGACY_OPENSEARCH',
    index_name: ENV.fetch('LEGACY_OPENSEARCH_INDEX'),
    shards: ENV.fetch('OPENSEARCH_INDEX_SHARDS', 1),
    replicas: ENV.fetch('OPENSEARCH_INDEX_REPLICAS', 1)
  )

  def self.create_index
    @index_creator.create_or_update_index(OPENSEARCH_CLIENT)
  end
end
