# frozen_string_literal: true

class ElasticFederalRegisterDocument
  extend Indexable
  OPTIMIZING_INCLUDES = [:federal_register_agencies].freeze

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => ElasticMappings::COMMON.deep_merge(
      properties: {
        abstract: ElasticSettings::TEXT,
        comments_close_on: { type: 'date', format: 'date' },
        publication_date: { type: 'date', format: 'date' },
        group_id: ElasticSettings::KEYWORD,
        document_number: ElasticSettings::KEYWORD,
        document_type: ElasticSettings::KEYWORD,
        federal_register_agency_ids: { type: 'integer' },
        title: ElasticSettings::TEXT,
        significant: { type: 'boolean' }
      }
    )
  }
end
