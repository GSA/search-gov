# frozen_string_literal: true

class ElasticNewsItem
  extend Indexable
  DUBLIN_CORE_AGG_NAMES = %i[contributor subject publisher].freeze

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => ElasticMappings::COMMON.deep_merge(
      properties: {
        rss_feed_url_id: { type: 'integer' },
        title: ElasticSettings::TEXT,
        description: ElasticSettings::TEXT,
        body: ElasticSettings::TEXT,
        published_at: { type: 'date' },
        popularity: { type: 'integer' },
        link: ElasticSettings::KEYWORD,
        contributor: { type: 'keyword' },
        subject: { type: 'keyword' },
        publisher: { type: 'keyword' },
        tags: { type: 'keyword' }
      }
    )
  }
end
