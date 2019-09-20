# frozen_string_literal: true

class ElasticSaytSuggestion
  extend Indexable

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => ElasticMappings::COMMON.deep_merge(
      properties: {
        affiliate_id: { type: 'integer' },
        phrase: {
          properties: { keyword: ElasticSettings::KEYWORD }.merge(
            ElasticSettings::TEXT[:properties]
          )
        },
        popularity: { type: 'integer' }
      }
    )
  }

end
