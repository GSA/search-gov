class RtuClicksRequest < ClicksRequest

  def save
    rtu_date_range = RtuDateRange.new(site.name, 'search')
    @available_dates = rtu_date_range.available_dates_range
    @end_date = end_date.nil? ? @available_dates.end : end_date.to_date
    @start_date = start_date.nil? ? (@end_date and @end_date.beginning_of_month) : start_date.to_date
    @top_urls = compute_top_url_stats
  end

  private

  def compute_top_url_stats
    url_query = DateRangeTopNQuery.new(site.name, start_date, end_date, { field: 'params.url', size: MAX_RESULTS })
    url_buckets = top_n(url_query.body)
    stats_from_buckets(url_buckets) if url_buckets.present?
  end

  def stats_from_buckets(url_buckets)
    url_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }
  end

  def top_n(query_body)
    ES::client_reader.search(index: "logstash-*", type: 'click', body: query_body, size: 0)["aggregations"]["agg"]["buckets"] rescue nil
  end

end
