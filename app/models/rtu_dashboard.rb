class RtuDashboard
  include LogstashPrefix
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
    top_query(TopNMissingQuery, field: 'raw', min_doc_count: 10)
  end

  def top_urls
    query = TopNQuery.new(@site.name, field: 'params.url')
    buckets = top_n(query.body, 'click')
    Hash[buckets.collect { |hash| [hash["key"], hash["doc_count"]] }] if buckets
  end

  def trending_urls
    redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)
    trending_urls_key = ['TrendingUrls', @site.name].join(':')
    redis.smembers(trending_urls_key)
  end

  def trending_queries
    query = TrendingTermsQuery.new(@site.name)
    buckets = top_n(query.body, 'search')
    extract_significant_terms(buckets) if buckets
  end

  def low_ctr_queries
    search_query = TopNExistsQuery.new(@site.name, field: 'raw', min_doc_count: 20, size: 100000)
    search_buckets = top_n(search_query.body, 'search')
    return nil unless search_buckets.present?
    searches_hash = Hash[search_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }]
    clicked_query = TopNQuery.new(@site.name, field: 'raw', size: 1000000)
    click_buckets = top_n(clicked_query.body, 'click')
    clicks_hash = Hash[click_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }]
    low_ctr_queries_from_hashes(clicks_hash, searches_hash)
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
    options = {width: 500, height: 250, title: 'Total Search Queries Over Time'}
    GoogleVisualr::Interactive::AreaChart.new(data_table, options)
  end

  def monthly_queries_histogram
    queries_by_month || []
  end

  private

  def queries_by_month
    query = MonthlyHistogramQuery.new(@site.name)
    yyyymm_buckets = top_n(query.body, 'search', "#{logstash_prefix(@filter_bots)}*")
    yyyymm_buckets.collect { |hash| [hash["key_as_string"], hash["doc_count"]] } if yyyymm_buckets
  end

  def low_ctr_queries_from_hashes(clicks_hash, searches_hash)
    searches_hash.inject([]) do |result, (term, qcount)|
      ccount = clicks_hash[term] || 0
      ctr = 100 * ccount / qcount
      result << [term, ctr] if ctr < 20
      result
    end.sort_by { |arr| arr.last }.first(10)
  end

  def mtd_count(type)
    count_query = CountQuery.new(@site.name)
    RtuCount.count("#{logstash_prefix(@filter_bots)}#{@day.strftime("%Y.%m.")}*", type, count_query.body)
  end

  def top_query(klass, options = {})
    query = klass.new(@site.name, options)
    buckets = top_n(query.body, 'search')
    buckets.collect { |hash| QueryCount.new(hash["key"], hash["doc_count"]) } if buckets
  end

  def top_n(query_body, type, index_date = nil)
    index = index_date || "#{logstash_prefix(@filter_bots)}#{@day.strftime("%Y.%m.%d")}"
    ES::client_reader.search(index: index, type: type, body: query_body, size: 0)["aggregations"]["agg"]["buckets"] rescue nil
  end

  def extract_significant_terms(buckets)
    buckets.inject([]) do |result, bucket|
      result << bucket["key"] if bucket["clientip_count"]["value"] >= 10
      result
    end
  end

end
