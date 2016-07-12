module RtuAnalyticsRequestable
  def save
    rtu_date_range = RtuDateRange.new(site.name, 'search')
    @available_dates = rtu_date_range.available_dates_range
    @end_date = end_date.nil? ? rtu_date_range.default_end : end_date.to_date
    @start_date = start_date.nil? ? rtu_date_range.default_start : start_date.to_date
    @top_stats = compute_top_stats
  end

  def persisted?
    false
  end
end
