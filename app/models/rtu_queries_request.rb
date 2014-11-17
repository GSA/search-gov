class RtuQueriesRequest
  MAX_RESULTS = 1000
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include LogstashPrefix

  attr_reader :start_date, :end_date, :top_queries, :available_dates, :query, :filter_bots

  attribute :site, Affiliate
  attribute :start_date, String
  attribute :end_date, String
  attribute :query, String
  attribute :filter_bots, Boolean

  def persisted?
    false
  end

  def save
    rtu_date_range = RtuDateRange.new(site.name, 'search')
    @available_dates = rtu_date_range.available_dates_range
    @end_date = end_date.nil? ? @available_dates.end : end_date.to_date
    @start_date = start_date.nil? ? (@end_date and @end_date.beginning_of_month) : start_date.to_date
    @top_queries = compute_top_query_stats
  end

  private

  def compute_top_query_stats
    search_query = TopQueryMatchQuery.new(site.name, query, start_date, end_date, { field: 'raw', size: MAX_RESULTS })
    search_click_buckets = top_n(search_query.body)
    stats_from_buckets(search_click_buckets) if search_click_buckets.present?
  end

  def stats_from_buckets(search_click_buckets)
    search_click_buckets.map { |bucket| extract_query_click_count(bucket) }.sort_by { |query_click_count| -query_click_count.queries }
  end

  def extract_query_click_count(bucket)
    term = bucket['key']
    types_buckets = bucket['type']['buckets']
    search_click_bucket = Hash[types_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }]
    qcount = search_click_bucket['search'] || 1
    ccount = search_click_bucket['click'] || 0
    ctr = 100 * ccount / qcount
    QueryClickCount.new(term, qcount, ccount, ctr)
  end

  def top_n(query_body)
    ES::client_reader.search(index: "#{logstash_prefix(filter_bots)}*", type: %w(search click), body: query_body, size: 0)["aggregations"]["agg"]["buckets"] rescue nil
  end

end
