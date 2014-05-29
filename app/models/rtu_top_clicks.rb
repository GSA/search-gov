class RtuTopClicks

  def initialize(query_body)
    @query_body = query_body
  end

  def top_n
    term_buckets = ES::client_reader.search(index: "logstash-*", type: 'click', body: @query_body, size: 0)["aggregations"]["agg"]["buckets"] rescue []
    term_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }
  end

end
