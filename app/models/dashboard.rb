class Dashboard
  attr_reader :trending_queries, :top_queries, :no_results, :low_ctr_queries, :trending_urls, :top_urls,
              :monthly_usage_chart, :monthly_queries_to_date, :monthly_clicks_to_date

  def initialize(site, day = Date.current)
    @day = day
    @site = site
  end

  def trending_urls
    redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
    trending_urls_key = ['TrendingUrls', @site.name].join(':')
    redis.smembers(trending_urls_key)
  end

  def no_results
    DailyQueryNoresultsStat.most_popular_no_results_queries(@day, @day, 10, @site.name)
  end

  def top_urls
    DailyClickStat.top_urls(@site.name, @day, @day, 10)
  end

  def top_queries
    query_counts = DailyQueryStat.most_popular_terms(@site.name, @day, @day, 10)
    query_counts.kind_of?(String) ? nil : query_counts
  end

  def trending_queries
    DailyQueryStat.trending_queries @site.name
  end

  def low_ctr_queries
    DailyQueryStat.low_ctr_queries @site.name
  end

  def monthly_usage_chart
    rows = DailyUsageStat.where(affiliate: @site.name).sum(:total_queries, group: "date_format(day,'%Y-%m')").to_a
    return nil unless rows.many?
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Date')
    data_table.new_column('number', 'Query Total')
    data_table.add_rows(rows)
    options = {width: 500, height: 250, title: 'Total Search Queries Over Time'}
    GoogleVisualr::Interactive::AreaChart.new(data_table, options)
  end

  def monthly_queries_to_date
    DailyUsageStat.monthly_totals(@day.year, @day.month, @site.name)
  end

  def monthly_clicks_to_date
    conditions = {affiliate_name: @site.name, day: @day.beginning_of_month..@day}
    DailySearchModuleStat.where(conditions).sum(:clicks)
  end
end
