class Analytics::QuerySearchesController < Analytics::AnalyticsController
  def index
    @search_query_term = params["query"]
    @search_results = DailyQueryStat.query_counts_for_terms_like(@search_query_term)
  end
end
