# frozen_string_literal: true

class RtuDashboard
  include LogstashPrefix
  include QueryCtrCollector
  attr_reader :trending_queries, :top_queries, :no_results, :low_ctr_queries, :trending_urls, :top_urls,
              :monthly_usage_chart, :monthly_queries_to_date, :monthly_clicks_to_date

  def initialize(site, day = Date.current, filter_bots)
    @site = site
    @day = day
    @filter_bots =filter_bots
  end

  def top_queries
    query_raw_human = RtuQueryRawHumanArray.new(@site.name, @day, @day, 10)
    top = query_raw_human.top_queries
    top.instance_of?(Array) ? top : nil
  end

  def no_results
    top_query(TopNMissingQuery, field: 'params.query.raw', min_doc_count: 10)
  end

  def top_urls
    query = TopNQuery.new(@site.name, 'click', field: 'params.url')
    buckets = top_n(query.body)
    Hash[buckets.collect { |hash| [hash["key"], hash["doc_count"]] }] if buckets
  end

  def trending_urls
    redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
    trending_urls_key = ['TrendingUrls', @site.name].join(':')
    redis.smembers(trending_urls_key)
  end

  def trending_queries
    query = TrendingTermsQuery.new(@site.name)
    buckets = top_n(query.body)
    extract_significant_terms(buckets) if buckets
  end

  def low_ctr_queries
    low_ctr_query = LowCtrQuery.new(@site.name, @day.beginning_of_day, @day.end_of_day)
    buckets = top_n(low_ctr_query.body)
    low_ctr_queries_from_buckets(buckets, 20, 10)
  end

  def monthly_queries_to_date
    mtd_count("search")
  end

  def monthly_clicks_to_date
    mtd_count("click")
  end

  def monthly_usage_chart
    rows = monthly_queries_histogram
    return nil unless rows.many?
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Date')
    data_table.new_column('number', 'Query Total')
    data_table.add_rows(rows)
    options = { width: 500, height: 250, title: 'Total Search Queries Over Time' }
    GoogleVisualr::Interactive::AreaChart.new(data_table, options)
  end

  def monthly_queries_histogram
    queries_by_month || []
  end

  private

  def queries_by_month
    query = MonthlyHistogramQuery.new(@site.name)
    yyyymm_buckets = top_n(query.body, "#{logstash_prefix(@filter_bots)}*")
    yyyymm_buckets.collect { |hash| [hash["key_as_string"], hash["doc_count"]] } if yyyymm_buckets
  end

  def mtd_count(type)
    count_query = CountQuery.new(@site.name, type)
    RtuCount.count(monthly_index_wildcard_spanning_date(@day, @filter_bots),
                   count_query.body)
  end

  def top_query(klass, options = {})
    query = klass.new(@site.name, 'search', **options)
    buckets = top_n(query.body)
    buckets.collect { |hash| QueryCount.new(hash["key"], hash["doc_count"]) } if buckets
  end

  def top_n(query_body, index_date = nil)
    index = index_date || "#{logstash_prefix(@filter_bots)}#{@day.strftime("%Y.%m.%d")}"
    Es::ELK.client_reader.search(
      index: index,
      body: query_body,
      size: 0
    )['aggregations']['agg']['buckets']
  rescue StandardError => error
    Rails.logger.error("Error querying top_n data: #{error}")
    []
  end

  def extract_significant_terms(buckets)
    buckets.inject([]) do |result, bucket|
      result << bucket["key"] if bucket["clientip_count"]["value"] >= 10
      result
    end
  end

end
