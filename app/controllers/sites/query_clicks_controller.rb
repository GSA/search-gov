class Sites::QueryClicksController < Sites::SetupSiteController
  def show
    @end_date = request["end_date"].to_date
    @start_date = request["start_date"].to_date
    @query = request["query"]
    @top_urls = params[:rtu].present? ? top_urls : QueriesClicksStat.top_urls(@site.name, @query, @start_date, @end_date)
  end

  private

  def top_urls
    query = DateRangeTopNFieldQuery.new(@site.name, @start_date, @end_date, 'raw', @query, { field: 'url', size: 0 })
    rtu_top_clicks = RtuTopClicks.new(query.body)
    rtu_top_clicks.top_n
  end

end
