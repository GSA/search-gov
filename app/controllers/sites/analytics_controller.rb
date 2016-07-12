class Sites::AnalyticsController < Sites::SetupSiteController
  before_filter :setup_site_analytics, :setup_date_range

  private

  def setup_site_analytics
    analytics = "#{@site.name}_analytics"
    session[analytics] ||= {}
    dates = RtuDateRange.new(@site.name, 'search')
    session[analytics][:range] = dates.available_dates_range
    session[analytics][:start] ||= dates.default_start
    session[analytics][:end] ||= dates.default_end
    @analytics_settings = session[analytics]
  end

  def setup_date_range
    @start_date = @analytics_settings[:start].to_date
    @end_date = @analytics_settings[:end].to_date
  end

  def set_analytics_range(start_date, end_date)
    @analytics_settings[:start], @analytics_settings[:end] = start_date, end_date
  end
end
