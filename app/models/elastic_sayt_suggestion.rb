# frozen_string_literal: true

class ElasticSaytSuggestion
  extend Indexable

  def self.logger
    Rails.logger
  end
  
  # Set logger level to FATAL to avoid logging connection errors
  self.logger.level = Logger::FATAL
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
