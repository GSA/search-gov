class SearchModuleCtr
  include LogstashPrefix

  def initialize(historical_days_back)
    @historical_days_back = historical_days_back
  end

  def search_module_ctrs
    query = ModuleBreakdownQuery.new
    query_body = query.body
    historical_buckets = module_ctrs(query_body, @historical_days_back)
    recent_buckets = module_ctrs(query_body)
    return [] unless historical_buckets.present? and recent_buckets.present?
    search_module_lookup_hash = SearchModule.to_tag_display_name_hash
    historical_hash = convert_to_hash(historical_buckets)
    recent_hash = convert_to_hash(recent_buckets)
    valid_entries = historical_hash.select { |k| search_module_lookup_hash.keys.include? k }
    valid_entries.collect do |key, historical_ics|
      search_module_name = search_module_lookup_hash[key]
      recent_ics = recent_hash[key] || ImpressionClickStat.new(0, 0)
      SearchModuleCtrStat.new(search_module_name, key, historical_ics, recent_ics)
    end
  end

  private

  def module_ctrs(query_body, historical_days_back = 0)
    params = { index: indexes_to_date(historical_days_back, true), type: %w(search click), body: query_body,
               search_type: 'count', ignore_unavailable: true }
    ES::client_reader.search(params)["aggregations"]["agg"]["buckets"] rescue nil
  end

  def convert_to_hash(buckets)
    Hash[buckets.collect { |hash| [hash["key"], extract_impression_click_stat(hash['type']['buckets'])] }] if buckets
  end

  def extract_impression_click_stat(types_buckets)
    search_click_bucket = Hash[types_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }]
    qcount = search_click_bucket['search'] || 0
    ccount = search_click_bucket['click'] || 0
    ImpressionClickStat.new(qcount, ccount)
  end

end