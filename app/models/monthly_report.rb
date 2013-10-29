class MonthlyReport

  def initialize(site, year, month)
    @site, @year, @month = site, year.to_i, month.to_i
    start_date = Date.civil(@year, @month)
    end_date = start_date.end_of_month
    @month_range = start_date..end_date
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
    boundary_mmyyyy(:most_recent_populated_date_for)
  end

  def earliest_mmyyyy
    boundary_mmyyyy(:oldest_populated_date_for)
  end

  private

  def boundary_mmyyyy(method)
    date = DailySearchModuleStat.send(method, @site.name) || Date.yesterday
    date.strftime('%m/%Y')
  end

end
