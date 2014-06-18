class RtuMonthlyReport < MonthlyReport
  include LogstashPrefix

  def initialize(site, year, month, filter_bots)
    super(site, year, month)
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

  private
  def month_count(type)
    count_query = CountQuery.new(@site.name)
    RtuCount.count("#{logstash_prefix(@filter_bots)}#{@year}.#{'%02d' % @month}.*", type, count_query.body)
  end

end
