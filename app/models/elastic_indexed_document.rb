# frozen_string_literal: true

class ElasticIndexedDocument
  extend Indexable

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => ElasticMappings::COMMON.deep_merge(
      properties: {
        affiliate_id: { type: 'integer' },
        title: ElasticSettings::TEXT,
        description: ElasticSettings::TEXT,
        body: ElasticSettings::TEXT,
        published_at: { type: 'date' },
        popularity: { type: 'integer' },
        url: ElasticSettings::KEYWORD
      }
    )
  }

end
