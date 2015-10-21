class RtuMonthlyReport
  include LogstashPrefix
  include QueryCtrCollector

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

  def no_result_queries
    @no_result_queries ||= begin
      query = DateRangeTopNMissingQuery.new(@site.name, @month_range.begin, @month_range.end, field: 'raw', min_doc_count: 20)
      rtu_top_queries = RtuTopQueries.new(query.body, @filter_bots)
      rtu_top_queries.top_n
    end
  end

  def low_ctr_queries
    @low_ctr_queries ||= begin
      low_ctr_query = LowCtrQuery.new(@site.name, @month_range.begin, @month_range.end)
      buckets = top_n(low_ctr_query.body, %w(search click))
      low_ctr_queries_from_buckets(buckets, 20, 10)
    end
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

  def clicks_hash
    clicked_query = DateRangeTopNQuery.new(@site.name, @month_range.begin, @month_range.end, field: 'raw', size: 1000000)
    rtu_top_clicks = RtuTopClicks.new(clicked_query.body, @filter_bots)
    click_buckets = rtu_top_clicks.top_n
    Hash[click_buckets]
  end
end
