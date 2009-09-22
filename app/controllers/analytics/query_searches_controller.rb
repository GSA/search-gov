class Analytics::QuerySearchesController < Analytics::AnalyticsController
  def index
    @search_query_term = params["query"]
    redirect_to analytics_home_page_path and return if @search_query_term.nil?
    @search_results = DailyQueryStat.most_popular_terms_like(@search_query_term)
  end
end
