class RtuTopN
  include LogstashPrefix

  def initialize(query_body, type, filter_bots, day)
    @query_body = query_body
    @type = type
    @filter_bots = filter_bots
    @day = day.present? ? day.strftime("%Y.%m.%d") : '*'
  end

  def top_n
    opts = { index: "#{logstash_prefix(@filter_bots)}#{@day}", type: @type, body: @query_body, size: 0 }
    term_buckets = ES::ELK.client_reader.search(opts)["aggregations"]["agg"]["buckets"] rescue []
    term_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }
  end

end
