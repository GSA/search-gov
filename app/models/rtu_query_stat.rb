class RtuQueryStat
  RESULTS_SIZE = 10
  INSUFFICIENT_DATA = "Not enough historic data to compute most popular"

  def self.most_popular_human_searches(affiliate_name, start_date, end_date, num_results = RESULTS_SIZE)
    return INSUFFICIENT_DATA if end_date.nil? or start_date.nil?
    date_range_top_n_query = DateRangeTopNQuery.new(affiliate_name, start_date, end_date, { field: 'raw', size: num_results })
    rtu_top_queries = RtuTopQueries.new(date_range_top_n_query.body, true)
    top_n = rtu_top_queries.top_n
    return INSUFFICIENT_DATA if top_n.empty?
    top_n.collect { |hash| QueryCount.new(hash.first, hash.last) }
  end
end