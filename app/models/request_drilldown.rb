class RequestDrilldown
  include LogstashPrefix
  MAX_RESULTS = 1000000

  def initialize(filtered_totals, type, drilldown_query_body)
    @filtered_totals = filtered_totals
    @type = type
    @drilldown_query_body = drilldown_query_body
  end

  def docs
    opts = { index: "#{logstash_prefix(@filtered_totals)}*", type: @type, body: @drilldown_query_body,
             size: MAX_RESULTS, sort: '@timestamp:asc' }
    ES::ELK.client_reader.search(opts)["hits"]["hits"].map { |hit| hit['_source'] } rescue []
  end

end