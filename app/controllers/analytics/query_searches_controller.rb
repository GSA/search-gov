class Analytics::QuerySearchesController < Analytics::AnalyticsController
  def index
    @search_query_term = params["query"]
    @start_date = Date.parse(params["analytics_search_start_date"]) rescue 1.month.ago.to_date
    @end_date = Date.parse(params["analytics_search_end_date"]) rescue Date.yesterday
    @search_results = DailyQueryStat.query_counts_for_terms_like(@search_query_term, @start_date, @end_date)
  end
end
