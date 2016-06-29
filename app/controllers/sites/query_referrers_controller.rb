class Sites::QueryReferrersController < Sites::AnalyticsController
  def show
    @query = request["query"]
    @top_urls = top_urls
  end

  private

  def top_urls
    query = DateRangeTopNFieldQuery.new(@site.name, @start_date, @end_date, 'raw', @query, { field: 'referrer', size: 0 })
    rtu_top_referrers = RtuTopQueries.new(query.body, @current_user.sees_filtered_totals?)
    rtu_top_referrers.top_n
  end

end
