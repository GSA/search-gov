class MonthlyReport

  def initialize(site, year, month)
    @site, @year, @month = site, year.to_i, month.to_i
    start_date = picked_date
    end_date = start_date.end_of_month
    @month_range = start_date..end_date
    rtu_date_range = RtuDateRange.new(@site.name, 'search')
    @available_rtu_dates = rtu_date_range.available_dates_range
  end

  def total_queries
    DailyUsageStat.monthly_totals(@year, @month, @site.name)
  end

  def total_clicks
    DailySearchModuleStat.where(affiliate_name: @site.name, day: @month_range).sum(:clicks)
  end

  def search_module_stats
    module_stats_analytics = ModuleStatsAnalytics.new(@month_range, @site.name)
    module_stats_analytics.module_stats
  end

  def picked_mmyyyy
    "#{@month}/#{@year}"
  end

  def picked_date
    Date.civil @year, @month
  end

  def latest_mmyyyy
    latest_legacy_date = boundary_mmyyyy(:most_recent_populated_date_for)
    latest = [latest_legacy_date, @available_rtu_dates.last].compact.max
    latest ||= Date.current
    latest.strftime('%m/%Y')
  end

  def earliest_mmyyyy
    earliest_legacy_date = boundary_mmyyyy(:oldest_populated_date_for)
    earliest = [earliest_legacy_date, @available_rtu_dates.first].compact.min
    earliest ||= Date.current
    earliest.strftime('%m/%Y')
  end

  private

  def boundary_mmyyyy(method)
    DailySearchModuleStat.send(method, @site.name)
  end

end