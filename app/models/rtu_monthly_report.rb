# frozen_string_literal: true

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
      query = DateRangeTopNMissingQuery.new(@site.name,
                                            'search',
                                            @month_range.begin,
                                            @month_range.end,
                                            field: 'params.query.raw',
                                            min_doc_count: 20)
      rtu_top_queries = RtuTopQueries.new(query.body, @filter_bots)
      rtu_top_queries.top_n
    end
  end

  def low_ctr_queries
    @low_ctr_queries ||= begin
      low_ctr_query = LowCtrQuery.new(@site.name, @month_range.begin, @month_range.end)
      indexes = monthly_index_wildcard_spanning_date(@month_range.begin, @filter_bots)
      buckets = top_n(low_ctr_query.body, indexes)
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
    count_query = CountQuery.new(@site.name, type)
    index = "#{logstash_prefix(@filter_bots)}#{@year}.#{'%02d' % @month}.*"
    RtuCount.count(index, count_query.body)
  end

  def mmyyyy(date)
    (date || Date.current).strftime('%m/%Y')
  end

  def top_n(query_body, indexes)
    ES::ELK.client_reader.search(
      index: indexes,
      body: query_body,
      size: 0
    )['aggregations']['agg']['buckets']
  rescue StandardError => error
    Rails.logger.error("Error querying top_n data: #{error}")
    []
  end
end
