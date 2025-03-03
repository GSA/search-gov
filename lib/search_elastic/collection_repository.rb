# frozen_string_literal: true

class SearchElastic::CollectionRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  client ES.client
  settings number_of_shards: 1, number_of_replicas: 1

  def source_hash(hash)
    hash['_source'].merge(id: hash['_id'])
  end

  def deserialize(hash)
    klass.new(source_hash(hash))
  end
end
