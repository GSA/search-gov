class Sites::ClickQueriesController < Sites::SetupSiteController
  def show
    @end_date = request["end_date"].to_date
    @start_date = request["start_date"].to_date
    @url = request["url"]
    @top_queries = params[:rtu].present? ? top_queries : QueriesClicksStat.top_queries(@site.name, @url, @start_date, @end_date)
  end

  private

  def top_queries
    query = DateRangeTopNFieldQuery.new(@site.name, @start_date, @end_date, 'params.url', @url, {field: 'raw', size: 0})
    rtu_top_clicks = RtuTopClicks.new(query.body)
    rtu_top_clicks.top_n
  end

end
