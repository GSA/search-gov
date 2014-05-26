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

  private

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

  def extract_significant_terms(buckets)
    buckets.inject([]) do |result, bucket|
      result << bucket["key"] if bucket["clientip"]["buckets"].size >= 10
      result
    end
  end

end
