class Sites::AnalyticsController < Sites::SetupSiteController
  before_filter :setup_site_analytics, :setup_date_range

  private

  def setup_site_analytics
    analytics = "#{@site.name}_analytics"
    session[analytics] ||= {}
    session[analytics][:range] = RtuDateRange.new(@site.name, 'search').available_dates_range
    session[analytics][:start] ||= session[analytics][:range].first
    session[analytics][:end] ||= session[analytics][:range].last
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
