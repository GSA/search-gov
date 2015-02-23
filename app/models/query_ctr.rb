class QueryCtr
  include LogstashPrefix
  include Ctrs

  def initialize(historical_days_back, module_tag, site_name)
    @historical_days_back = historical_days_back
    @module_tag = module_tag
    @site_name = site_name
  end

  def query_ctrs
    query = QueryBreakdownForSiteModuleQuery.new(@module_tag, @site_name)
    query_body = query.body
    historical_buckets = ctrs(query_body, @historical_days_back)
    recent_buckets = ctrs(query_body)
    return [] unless historical_buckets.present?
    historical_hash = convert_to_hash(historical_buckets)
    recent_hash = convert_to_hash(recent_buckets)
    historical_hash.collect do |key, historical_ics|
      recent_ics = recent_hash[key] || ImpressionClickStat.new(0, 0)
      QueryCtrStat.new(key, historical_ics, recent_ics)
    end
  end

end