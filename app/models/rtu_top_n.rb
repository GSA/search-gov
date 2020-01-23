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

  # Results representing a given percentage of all results by doc_count
  def top_n_to_percentage(percent)
    top = top_n
    total = top.map(&:last).sum
    cumulative_count = 0.0
    top_to_percentage = []

    while (cumulative_count / total) * 100 < percent
      result = top.shift
      top_to_percentage << result
      cumulative_count += result[1]
    end
    top_to_percentage
  end
end
