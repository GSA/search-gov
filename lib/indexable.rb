module Indexable
  attr_accessor :default_sort, :mappings, :settings
  attr_writer :index_name, :index_type

  def index_name
    assign_index_name unless defined?(@index_name)
    @index_name
  end

  def index_type
    assign_index_type unless defined?(@index_type)
    @index_type
  end

  def delete_index
    ES::client.indices.delete index: index_name
  end

  def create_index
    ES::client.indices.create(index: index_name, body: { settings: settings, mappings: mappings })
  end

  def index_exists?
    ES::client.indices.exists index: index_name
  end

  def recreate_index
    delete_index if index_exists?
    create_index
  end

  def index(record)
    hash = { index: index_name, type: index_type, id: record[:id], body: record.except(:id, :ttl) }
    hash.merge!(ttl: record[:ttl]) if record[:ttl]
    ES::client.index(hash)
    Rails.logger.info "Indexed entry #{record[:id]} to index #{index_name}"
  end

  def delete(id)
    ES::client.delete(index: index_name, type: index_type, id: id)
  rescue Exception => e
    Rails.logger.error "Problem in #{self.name}#delete(): #{e}"
    nil
  end

  def search_for(options)
    query = "#{self.name}Query".constantize.new options
    ActiveSupport::Notifications.instrument("query.elasticsearch", payload: { model: self.name, term: query.body }) do
      search(query)
    end
  rescue Exception => e
    Rails.logger.error "Problem in #{self.name}#search_for(): #{e}"
    nil
  end

  def commit
    ES::client.indices.refresh index: index_name
  end

  private

  def assign_index_name
    self.index_name = [ES::INDEX_PREFIX, self.name.tableize].join(':').freeze
  end

  def assign_index_type
    self.index_type = self.name.underscore.freeze
  end

  def search(query)
    params = { preference: '_local', index: index_name, type: index_type, body: query.body,
               from: query.offset, size: query.size, sort: query.sort }
    hits = ES::client.search(params)['hits']
    hits['offset'] = query.offset
    "#{self.name}Results".constantize.new(hits)
  end

end
