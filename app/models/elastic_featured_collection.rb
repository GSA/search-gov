class ElasticFeaturedCollection
  extend Indexable

  self.settings = ElasticSettings::COMMON

  self.mappings = {
      index_type => ElasticMappings::BEST_BET.deep_merge(
          properties: { link_titles: { type: 'string', term_vector: 'with_positions_offsets' }})
  }

end