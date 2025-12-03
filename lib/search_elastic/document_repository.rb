# frozen_string_literal: true

class SearchElastic::DocumentRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  client ES.client
  settings number_of_shards: ENV.fetch('NUMBER_OF_SHARDS', 1), number_of_replicas: ENV.fetch('NUMBER_OF_REPLICAS', 1)

  def source_hash(hash)
    hash['_source'].merge(id: hash['_id'])
  end

  def serialize(document)
    document_hash = ActiveSupport::HashWithIndifferentAccess.new(super)
    Serde.serialize_hash(document_hash, document_hash[:language])
  end

  def deserialize(hash)
    doc_hash = source_hash(hash)
    deserialized_hash = Serde.deserialize_hash(doc_hash,
                                               doc_hash['language'])
    klass.new deserialized_hash
  end
end
