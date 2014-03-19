class ElasticDailyQueryStat
  extend Indexable

  self.settings = ElasticSettings::COMMON.deep_merge(
    index: {
      number_of_shards: 2,
      number_of_replicas: 0
    }
  )

  self.mappings = {
    index_type => {
      dynamic: :strict,
      properties: {
        affiliate: { type: 'string', analyzer: 'keyword' },
        day: { type: 'date', format: 'YYYY-MM-dd' },
        query: { type: 'string', analyzer: 'snowball' },
        times: { type: 'integer', index: :not_analyzed },
        id: { type: 'integer', index: :not_analyzed, include_in_all: false } }
    }
  }

end