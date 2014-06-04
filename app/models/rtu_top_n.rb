class RtuTopN

  def initialize(query_body, type, filter_bots)
    @query_body = query_body
    @type = type
    @filter_bots = filter_bots
  end

  def top_n
    term_buckets = ES::client_reader.search(index: logstash_wildcard, type: @type, body: @query_body, size: 0)["aggregations"]["agg"]["buckets"] rescue []
    term_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }
  end

  private

  def logstash_wildcard
    prefix = @filter_bots ? "human-" : ""
    "#{prefix}logstash-*"
  end

end
