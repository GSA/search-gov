class Analytics::QuerySearchesController < Analytics::AnalyticsController
  def index
    @search_query_term = params["query"]
    redirect_to analytics_home_page_path and return if @search_query_term.nil?
    @starts_with = true
    @starts_with = false if params["search_type"] && params["search_type"] == "contains"
    @search_results = DailyQueryStat.most_popular_terms_like(@search_query_term, @starts_with)
  end
end
