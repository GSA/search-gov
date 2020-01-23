class Sites::ClickQueriesController < Sites::AnalyticsController
  def show
    @url = request["url"]
    @top_queries = top_queries
  end

  private

  def top_queries
    query = DateRangeTopNFieldQuery.new(@site.name, @start_date, @end_date, 'params.url', @url, {field: 'raw', size: 0})
    rtu_top_clicks = RtuTopClicks.new(query.body, @current_user.sees_filtered_totals?)
    rtu_top_clicks.top_n
  end
end
