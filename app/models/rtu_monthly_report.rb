class RtuMonthlyReport
  include LogstashPrefix

  def initialize(site, year, month, filter_bots)
    @site, @year, @month = site, year.to_i, month.to_i
    start_date = picked_date
    end_date = start_date.end_of_month
    @month_range = start_date..end_date
    rtu_date_range = RtuDateRange.new(@site.name, 'search')
    @available_rtu_dates = rtu_date_range.available_dates_range
    @filter_bots = filter_bots
  end

  def total_queries
    month_count('search')
  end

  def total_clicks
    month_count('click')
  end

  def search_module_stats
    module_stats_analytics = RtuModuleStatsAnalytics.new(@month_range, @site.name, @filter_bots)
    module_stats_analytics.module_stats
  end

  def picked_mmyyyy
    "#{@month}/#{@year}"
  end

  def picked_date
    Date.civil @year, @month
  end

  def latest_mmyyyy
    mmyyyy(@available_rtu_dates.last)
  end

  def earliest_mmyyyy
    mmyyyy(@available_rtu_dates.first)
  end

  private

  def month_count(type)
    count_query = CountQuery.new(@site.name)
    RtuCount.count("#{logstash_prefix(@filter_bots)}#{@year}.#{'%02d' % @month}.*", type, count_query.body)
  end

  def mmyyyy(date)
    (date || Date.current).strftime('%m/%Y')
  end

end
