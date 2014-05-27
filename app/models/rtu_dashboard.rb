class RtuDashboard < Dashboard

  def top_queries
    top_query(TopNQuery, field: 'raw')
  end

  def no_results
    top_query(TopNMissingQuery, field: 'raw', min_doc_count: 10)
  end

  def top_urls
    query = TopNQuery.new(@site.name, field: 'params.url')
    buckets = top_n(query.body, 'click')
    Hash[buckets.collect { |hash| [hash["key"], hash["doc_count"]] }] if buckets
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
    low_ctr_queries = searches_hash.inject([]) do |result, (term, qcount)|
      ccount = clicks_hash[term] || 0
      ctr = 100 * ccount / qcount
      result << [term, ctr] if ctr < 20
      result
    end
    low_ctr_queries.sort_by { |arr| arr.last }.first(10)
  end

  def monthly_queries_to_date
    mtd_count("search")
  end

  def monthly_clicks_to_date
    mtd_count("click")
  end

  private

  def mtd_count(type)
    count_query = CountQuery.new(@site.name)
    result = count(count_query.body, type)
    result["count"] if result
  end

  def top_query(klass, options = {})
    query = klass.new(@site.name, options)
    buckets = top_n(query.body, 'search')
    buckets.collect { |hash| QueryCount.new(hash["key"], hash["doc_count"]) } if buckets
  end

  def top_n(query_body, type)
    search(query_body, type)["aggregations"]["agg"]["buckets"] rescue nil
  end

  def search(query_body, type)
    ES::client_reader.search(index: "logstash-#{@day.strftime("%Y.%m.%d")}", type: type, body: query_body, size: 0)
  rescue Exception => e
    nil
  end

  def count(query_body, type)
    ES::client_reader.count(index: "logstash-#{@day.strftime("%Y.%m.")}*", type: type, body: query_body)
  rescue Exception => e
    nil
  end

  def extract_significant_terms(buckets)
    buckets.inject([]) do |result, bucket|
      result << bucket["key"] if bucket["clientip"]["buckets"].size >= 10
      result
    end
  end

end
