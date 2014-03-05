module Indexable
  attr_accessor :default_sort, :mappings, :settings

  DELIMTER = '-'
  NO_HITS = { 'total' => 0, 'offset' => 0, 'hits' => [] }

  def index_name
    @index_name ||= [base_index_name, Time.now.strftime("%Y%m%d%H%M%S%L")].join(DELIMTER)
  end

  def reader_alias
    self.index_alias :reader
  end

  def writer_alias
    self.index_alias :writer
  end

  def index_alias(type)
    [self.base_index_name, type].join(DELIMTER)
  end

  def index_type
    @index_type ||= self.name.underscore
  end

  def base_index_name
    [ES::INDEX_PREFIX, self.name.tableize].join(DELIMTER)
  end

  def delete_index
    ES::client.indices.delete(index: "#{base_index_name}#{DELIMTER}*")
  end

  def create_index
    ES::client.indices.create(index: index_name, body: { settings: settings, mappings: mappings })
    ES::client.indices.put_alias index: index_name, name: writer_alias
    ES::client.indices.put_alias index: index_name, name: reader_alias
  end

  def migrate_writer
    @index_name = nil
    ES::client.indices.create(index: index_name, body: { settings: settings, mappings: mappings })
    update_alias(writer_alias)
  end

  def migrate_reader
    old_index = ES::client.indices.get_alias(name: reader_alias).keys.first
    new_index = ES::client.indices.get_alias(name: writer_alias).keys.first
    update_alias(reader_alias, new_index)
    ES::client.indices.delete(index: old_index)
  end

  def index_exists?
    ES::client.indices.get_alias(name: writer_alias)
    true
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    false
  end

  def recreate_index
    delete_index if index_exists?
    create_index
  end

  def index(records)
    records = [records] unless records.is_a?(Array)
    ES::client.bulk(body: bulkify(records))
    Rails.logger.info "Indexed #{records.size} entries to index #{index_name}"
  end

  def bulkify(records)
    records.reduce([]) do |bulk_array, record|
      meta_data = { _index: writer_alias, _type: index_type, _id: record[:id] }
      meta_data.merge!(_ttl: record[:ttl]) if record[:ttl]
      bulk_array << { index: meta_data }
      bulk_array << record.except(:id, :ttl)
    end
  end

  def delete(ids)
    ids = [ids] unless ids.is_a?(Array)
    ES::client.bulk(body: bulkify_delete(ids))
  rescue Exception => e
    Rails.logger.error "Problem in #{self.name}#delete(): #{e}"
    nil
  end

  def bulkify_delete(ids)
    ids.map do |id|
      { delete: { _index: writer_alias, _type: index_type, _id: id } }
    end
  end

  def search_for(options)
    query = "#{self.name}Query".constantize.new options
    ActiveSupport::Notifications.instrument("query.elasticsearch", payload: { model: self.name, term: query.body }) do
      search(query)
    end
  rescue Exception => e
    Rails.logger.error "Problem in #{self.name}#search_for(): #{e}"
    "#{self.name}Results".constantize.new(NO_HITS, nil)
  end

  def commit
    ES::client.indices.refresh index: writer_alias
  end

  private

  def search(query)
    params = { preference: '_local', index: reader_alias, type: index_type, body: query.body, from: query.offset, size: query.size }
    params.merge!(sort: query.sort) if query.sort.present?
    result = ES::client.search(params)
    hits = result['hits']
    hits['offset'] = query.offset
    aggregations = result['aggregations']
    "#{self.name}Results".constantize.new(hits, aggregations)
  end

  def update_alias(alias_name, new_index = index_name)
    old_index = ES::client.indices.get_alias(name: alias_name).keys.first
    ES::client.indices.update_aliases body: {
      actions: [
        { remove: { index: old_index, alias: alias_name } },
        { add: { index: new_index, alias: alias_name } }
      ]
    }
  end

end
