class RtuQueryRawHumanArray
  MAX_RESULTS = 1000000
  RESULTS_SIZE = 10
  INSUFFICIENT_DATA = "Not enough historic data to compute most popular"

  def initialize(site_name, start_date, end_date, num_results = RESULTS_SIZE)
    @site_name, @start_date, @end_date, @num_results = site_name, start_date, end_date, num_results
  end

  def top_queries
    return INSUFFICIENT_DATA if @end_date.nil? or @start_date.nil?
    date_range_top_n_query = DateRangeTopNQuery.new(@site_name, @start_date, @end_date, { field: 'raw', size: MAX_RESULTS })
    rtu_top_queries = RtuTopQueries.new(date_range_top_n_query.body, false)
    query_raw_cnt_arr = rtu_top_queries.top_n
    rtu_top_human_queries = RtuTopQueries.new(date_range_top_n_query.body, true)
    query_human_cnt_hash = Hash[rtu_top_human_queries.top_n]
    return INSUFFICIENT_DATA if query_human_cnt_hash.empty?
    query_raw_human_arr = query_raw_cnt_arr.map do |query_term, raw_count|
      human_count = query_human_cnt_hash[query_term] || 0
      [query_term, raw_count, human_count]
    end
    query_raw_human_arr.sort_by { |a| -a.last }.first(@num_results)
  end

end
