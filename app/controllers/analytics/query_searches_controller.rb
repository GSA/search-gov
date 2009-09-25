class Analytics::QuerySearchesController < Analytics::AnalyticsController
  def index
    @search_query_term = params["query"]
    @search_results = []
    unless @search_query_term.blank?
      @starts_with = true
      @starts_with = false if params["search_type"] && params["search_type"] == "contains"
      @search_results = DailyQueryStat.most_popular_terms_like(@search_query_term, @starts_with)
    end
  end
end
