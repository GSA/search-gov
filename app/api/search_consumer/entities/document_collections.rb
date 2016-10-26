module SearchConsumer
  module Entities
    class DocumentCollections < Grape::Entity
      expose :id, documentation: { type: 'integer' }
      expose :name, documentation: { type: 'string', desc: 'Document Collection name'}
      expose :advanced_search_enabled,
        documentation: { type: 'boolean',
                         desc: 'Specifies whether this document collection should be included in the "limit to" drop-down in the advanced search form.' }

    end
  end
end
