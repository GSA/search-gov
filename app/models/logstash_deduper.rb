# frozen_string_literal: true

class LogstashDeduper
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary
  SCROLL_SIZE = 5000

  def self.perform(day_str)
    index_name = "logstash-#{day_str}"
    seen, dupe_ids = Set.new, []
    client = Es::ELK.client_reader
    result = client.search(
      index: index_name,
      type: 'search',
      scroll: '5m',
      size: SCROLL_SIZE,
      sort: '_doc'
    )
    while result = client.scroll(scroll_id: result['_scroll_id'], scroll: '5m') and not result['hits']['hits'].empty?
      result['hits']['hits'].each do |d|
        idx = d['_source'].hash.to_s
        if seen.include? idx
          dupe_ids << d['_id']
        else
          seen << idx
        end
      end
    end
    dupe_ids.in_groups_of(SCROLL_SIZE, false) do |group|
      body = group.collect { |id| Hash[delete: { _index: index_name, _type: "search", _id: id }] }
      client.bulk(body: body)
    end
  end

end
