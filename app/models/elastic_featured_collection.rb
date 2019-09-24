# frozen_string_literal: true

class ElasticFeaturedCollection
  extend Indexable
  OPTIMIZING_INCLUDES = [:affiliate, :featured_collection_keywords, :featured_collection_links].freeze

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => ElasticMappings::BEST_BET.deep_merge(
      properties: { link_titles: ElasticSettings::TEXT }
    )
  }

end
