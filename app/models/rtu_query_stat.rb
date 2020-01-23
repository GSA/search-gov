class RtuQueryStat
  RESULTS_SIZE = 10

  def self.top_n_overall_human_searches(since, num_results = RESULTS_SIZE)
    top_n_overall_human_searches_query = OverallTopNQuery.new(since, { field: 'raw', size: num_results })
    rtu_top_queries = RtuTopQueries.new(top_n_overall_human_searches_query.body, true)
    rtu_top_queries.top_n
  end
end