class ElasticFederalRegisterDocument
  extend Indexable
  OPTIMIZING_INCLUDES = [:federal_register_agencies].freeze

  self.settings = ElasticSettings::COMMON

  self.mappings = {
    index_type => {
      dynamic: :strict,
      properties: {
        abstract: { type: 'string', term_vector: 'with_positions_offsets', analyzer: 'en_analyzer' },
        comments_close_on: { type: 'date', format: 'date' },
        publication_date: { type: 'date', format: 'date' },
        group_id: ElasticSettings::KEYWORD,
        document_number: ElasticSettings::KEYWORD,
        document_type: ElasticSettings::KEYWORD,
        federal_register_agency_ids: { type: 'integer' },
        title: { type: 'string', term_vector: 'with_positions_offsets', analyzer: 'en_analyzer' },
        significant: { type: 'boolean' },
        id: { type: 'integer', index: :not_analyzed, include_in_all: false }
      }
    }
  }

end
