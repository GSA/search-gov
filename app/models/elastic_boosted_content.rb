# frozen_string_literal: true

class ElasticBoostedContent
  extend Indexable
  OPTIMIZING_INCLUDES = [:affiliate, :boosted_content_keywords].freeze

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => ElasticMappings::BEST_BET.deep_merge(
      properties: {
        description: ElasticSettings::TEXT,
        url: ElasticSettings::KEYWORD
      }
    )
  }

end
