class SearchModuleCtr
  include LogstashPrefix
  include Ctrs

  def initialize(historical_days_back)
    @historical_days_back = historical_days_back
  end

  def search_module_ctrs
    query = ModuleBreakdownQuery.new
    query_body = query.body
    historical_buckets = ctrs(query_body, @historical_days_back)
    recent_buckets = ctrs(query_body)
    return [] unless historical_buckets.present?
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

end
