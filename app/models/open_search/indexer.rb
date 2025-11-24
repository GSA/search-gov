# frozen_string_literal: true
require 'search_elastic/index_create'

class OpenSearch::Indexer

  @index_creator = SearchElasticIndexCreator.new(
    service_name: 'OPENSEARCH',
    index_name: ENV.fetch('OPENSEARCH_SEARCH_INDEX'),
    shards: ENV.fetch('SEARCHELASTIC_INDEX_SHARDS', 1),
    replicas: ENV.fetch('SEARCHELASTIC_INDEX_REPLICAS', 1)
  )

  def self.create_index
    @index_creator.create_or_update_index(OPENSEARCH_CLIENT)
  end
end
