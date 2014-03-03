class Sites::TopQueriesController < Sites::SetupSiteController
  CSV_RESULTS_SIZE = 1000000

  def new
    @top_query_counts = DailyQueryStat.most_popular_terms(@site.name, params[:start_date].to_date, params[:end_date].to_date, CSV_RESULTS_SIZE)
    @top_query_counts = [] if @top_query_counts.instance_of? String
    respond_to do |format|
      format.csv do
        render_csv("top_queries_#{@site.name}_#{params[:start_date]}_#{params[:end_date]}")
      end
    end
  end
end
