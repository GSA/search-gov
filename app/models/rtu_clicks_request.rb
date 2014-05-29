class RtuClicksRequest < ClicksRequest

  def save
    rtu_date_range = RtuDateRange.new(site.name, 'search')
    @available_dates = rtu_date_range.available_dates_range
    @end_date = end_date.nil? ? @available_dates.end : end_date.to_date
    @start_date = start_date.nil? ? (@end_date and @end_date.beginning_of_month) : start_date.to_date
    @top_urls = compute_top_url_stats
  end

  private

  def compute_top_url_stats
    query = DateRangeTopNQuery.new(site.name, start_date, end_date, { field: 'params.url', size: MAX_RESULTS })
    rtu_top_clicks = RtuTopClicks.new(query.body)
    rtu_top_clicks.top_n
  end

end
