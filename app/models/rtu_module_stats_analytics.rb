class RtuModuleStatsAnalytics
  include LogstashPrefix

  SPARKLINE_MONTHS_TO_SHOW = 2

  SearchModuleStat = Struct.new(:module_tag, :display_name, :clicks, :impressions, :clickthru_ratio, :historical_ctr, :average_clickthru_ratio)

  def initialize(daterange, affiliate_name, filter_bots)
    @daterange = daterange
    @affiliate_name = affiliate_name
    @filter_bots = filter_bots
  end

  def module_stats
    affiliate_stats = clicks_and_impressions(@affiliate_name)
    augment_affiliate_stats(affiliate_stats) if affiliate_stats.present?
    affiliate_stats || []
  end

  private

  def augment_affiliate_stats(affiliate_stats)
    total_clicks, total_impressions = 0, 0
    module_sparkline_hash = module_sparklines
    global_ctr_hash = Hash[clicks_and_impressions.map { |result| [result.module_tag, result.clickthru_ratio] }]
    affiliate_stats.each do |stat|
      total_clicks += stat.clicks
      total_impressions += stat.impressions
      stat.average_clickthru_ratio = global_ctr_hash[stat.module_tag]
      stat.historical_ctr = module_sparkline_hash[stat.module_tag] || []
    end
    affiliate_stats << SearchModuleStat.new(nil, 'Total', total_clicks, total_impressions,
                                            clickthru_ratio(total_clicks, total_impressions), module_sparkline_hash['Total'])
  end

  def module_sparklines
    query = ModuleSparklineQuery.new(@affiliate_name)
    buckets = es_search("#{logstash_prefix(@filter_bots)}*", query.body, 'agg')
    module_hash = Hash[buckets.map { |bucket| [bucket['key'], sparkline_from_buckets(bucket['histogram']['buckets'])] }]
    module_hash['Total'] = total_sparkline
    module_hash
  end

  def total_sparkline
    query = OverallSparklineQuery.new(@affiliate_name)
    buckets = es_search("#{logstash_prefix(@filter_bots)}*", query.body, 'histogram')
    sparkline_from_buckets(buckets)
  end

  def sparkline_from_buckets(buckets)
    buckets.collect do |search_click_bucket|
      types_buckets = search_click_bucket['type']['buckets']
      search_click_bucket = Hash[types_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }]
      qcount = search_click_bucket['search'] || 0
      ccount = search_click_bucket['click'] || 0
      qcount.zero? ? 0 : clickthru_ratio(ccount, qcount)
    end
  end

  def clicks_and_impressions(site_name = nil)
    query = ModuleBreakdownQuery.new(site_name)
    search_click_buckets = top_n(query.body)
    stats_from_buckets(search_click_buckets) if search_click_buckets.present?
  end

  def clickthru_ratio(clicks, impressions)
    100.0 * clicks / impressions
  end

  def top_n(query_body)
    es_search(monthly_index_wildcard_spanning_date(@daterange.first, @filter_bots), query_body, 'agg')
  end

  def es_search(index, query_body, agg_name)
    ES::ELK.client_reader.search(
      index: index,
      body: query_body,
      size: 0
    )['aggregations'][agg_name]['buckets']
  rescue StandardError
    nil
  end

  def stats_from_buckets(search_click_buckets)
    search_click_buckets.map { |bucket| extract_query_click_count(bucket) }.compact.sort_by { |query_click_count| -query_click_count.clicks }
  end

  def extract_query_click_count(bucket)
    term = bucket['key']
    search_module = SearchModule.find_by_tag(term)
    return nil unless search_module.present?
    module_name = search_module.display_name
    types_buckets = bucket['type']['buckets']
    search_click_bucket = Hash[types_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }]
    qcount = search_click_bucket['search'] || 0
    ccount = search_click_bucket['click'] || 0
    SearchModuleStat.new(term, module_name, ccount, qcount, clickthru_ratio(ccount, qcount)) unless qcount.zero?
  end

end
