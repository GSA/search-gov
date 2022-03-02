# frozen_string_literal: true

module Indexable
  attr_accessor :default_sort, :mappings, :settings

  DELIMTER = '-'
  NO_HITS = { 'hits' => { 'total' => 0, 'offset' => 0, 'hits' => [] } }.freeze

  def index_name
    @index_name ||= [base_index_name, Time.now.strftime('%Y%m%d%H%M%S%L')].join(DELIMTER)
  end

  def reader_alias
    index_alias(:reader)
  end

  def writer_alias
    index_alias(:writer)
  end

  def index_alias(type)
    [base_index_name, type].join(DELIMTER)
  end

  def index_type
    @index_type ||= name.underscore
  end

  def base_index_name
    [Es::INDEX_PREFIX, name.tableize].join(DELIMTER)
  end

  def delete_index
    Es::CustomIndices.client_writers.each { |client| client.indices.delete(index: "#{base_index_name}#{DELIMTER}*") }
  end

  def create_index
    Es::CustomIndices.client_writers.each do |client|
      client.indices.create(
        index: index_name,
        body: { settings: settings, mappings: mappings },
        include_type_name: true
      )
      client.indices.put_alias(index: index_name, name: writer_alias)
      client.indices.put_alias(index: index_name, name: reader_alias)
    end
  end

  def migrate_writer
    @index_name = nil
    Es::CustomIndices.client_writers.each do |client|
      client.indices.create(
        index: index_name,
        body: { settings: settings, mappings: mappings },
        include_type_name: true
      )
    end
    update_alias(writer_alias)
  end

  def migrate_reader
    old_index = Es::CustomIndices.client_reader.indices.get_alias(name: reader_alias).keys.first
    new_index = Es::CustomIndices.client_reader.indices.get_alias(name: writer_alias).keys.first
    update_alias(reader_alias, new_index)
    Es::CustomIndices.client_writers.each { |client| client.indices.delete(index: old_index) }
  end

  def index_exists?
    Es::CustomIndices.client_reader.indices.get_alias(name: writer_alias)
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
    bulk(bulkify(records))
    Rails.logger.info "Indexed #{records.size} entries to index #{index_name}"
  end

  def delete(ids)
    ids = [ids] unless ids.is_a?(Array)
    bulk(bulkify_delete(ids))
  end

  def delete_by_query(options)
    query = options.collect { |key, value| [key, value].join(':') }.join(' ')
    Es::CustomIndices.client_writers.each { |client| client.delete_by_query(index: writer_alias, q: query, default_operator: 'AND') }
  end

  def bulkify(records)
    records.reduce([]) do |bulk_array, record|
      meta_data = { _index: writer_alias, _type: index_type, _id: record[:id] }
      meta_data.merge!(_ttl: record[:ttl]) if record[:ttl]
      bulk_array << { index: meta_data }
      bulk_array << record.except(:id, :ttl)
    end
  end

  def bulkify_delete(ids)
    ids.map do |id|
      { delete: { _index: writer_alias, _type: index_type, _id: id } }
    end
  end

  def search_for(options)
    query = "#{name}Query".constantize.new(options)
    ActiveSupport::Notifications.instrument('elastic_search.usasearch', query: query.body, index: name) do
      search(query)
    end
  rescue StandardError => e
    Rails.logger.error "Problem in #{name}#search_for(): #{e}"
    "#{name}Results".constantize.new(NO_HITS)
  end

  def commit
    Es::CustomIndices.client_writers.each { |client| client.indices.refresh(index: writer_alias) }
  end

  def bulk(body)
    Es::CustomIndices.client_writers.each { |client| client_bulk(client, body) }
  end

  def optimize
    Es::CustomIndices.client_writers.each { |client| client.indices.optimize }
  end

  private

  def search(query)
    params = { preference: '_local',
               index: reader_alias,
               type: index_type,
               body: query.body,
               from: query.offset,
               size: query.size,
               # For compatibility with ES 6. This parameter will be removed in ES 8.
               # https://www.elastic.co/guide/en/elasticsearch/reference/current/breaking-changes-7.0.html#hits-total-now-object-search-response
               rest_total_hits_as_int: true }
    params[:sort] = query.sort if query.sort.present?

    result = Es::CustomIndices.client_reader.search(params)
    result['hits']['offset'] = query.offset
    "#{name}Results".constantize.new(result)
  end

  def update_alias(alias_name, new_index = index_name)
    old_index = Es::CustomIndices.client_reader.indices.get_alias(name: alias_name).keys.first
    Es::CustomIndices.client_writers.each do |client|
      client.indices.update_aliases(
        body: {
          actions: [
            { remove: { index: old_index, alias: alias_name } },
            { add: { index: new_index, alias: alias_name } }
          ]
        }
      )
    end
  end

  def client_bulk(client, body)
    response = client.bulk(body: body)
    handle_bulk_errors(client, response) if response['errors']
  rescue StandardError => e
    Rails.logger.error "#{Time.now} Client error in #{name}#client_bulk(): #{e}; host: #{host_list(client) }; body: #{body}"
    nil
  end

  def handle_bulk_errors(client, response)
    errors = response['items'].select { |item| item.values.first['status'] >= 400 }
    Rails.logger.error "#{Time.now} Bulk API error in #{name}#client_bulk(): #{errors}; host: #{host_list(client) }"
  end

  def host_list(client)
    client.transport.hosts.collect { |h| h[:host] }.join(',')
  end

end
