class SiteCtr
  include LogstashPrefix
  include Ctrs

  def initialize(historical_days_back, module_tag)
    @historical_days_back = historical_days_back
    @module_tag = module_tag
  end

  def site_ctrs
    query = SiteBreakdownForModuleQuery.new(@module_tag)
    query_body = query.body
    historical_buckets = ctrs(query_body, @historical_days_back)
    recent_buckets = ctrs(query_body)
    return [] unless historical_buckets.present?
    site_lookup_hash = Affiliate.to_name_site_hash
    historical_hash = convert_to_hash(historical_buckets)
    recent_hash = convert_to_hash(recent_buckets)
    valid_entries = historical_hash.select { |k| site_lookup_hash.keys.include? k }
    valid_entries.collect do |key, historical_ics|
      site = site_lookup_hash[key]
      recent_ics = recent_hash[key] || ImpressionClickStat.new(0, 0)
      SiteCtrStat.new(site, historical_ics, recent_ics)
    end
  end
end
