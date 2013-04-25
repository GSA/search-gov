class GoogleFormattedQuery < FormattedQuery
  def initialize(user_query, options = {})
    super(options)
    @query = query_with_sites(user_query)
  end

  private

  def query_with_sites(user_query)
    site_and_no_minus_site = user_query.include?('site:') && !user_query.include?('-site:')
    remaining_chars = QUERY_STRING_ALLOCATION - user_query.length
    domains = site_and_no_minus_site ? nil : fill_domains_to_remainder(remaining_chars)
    excluded = user_query.include?('site:') ? nil : @excluded_domains.map { |ed| "-site:#{ed}" }.join(" AND ")
    keywords = @scope_keywords.collect { |keyword| "\"#{keyword}\"" }.join(" OR ")
    sites_keywords = [user_query]
    sites_keywords << "#{excluded}" unless excluded.blank?
    sites_keywords << "#{domains}" unless domains.blank?
    sites_keywords << "#{keywords}" unless keywords.blank?
    sites_keywords.join(' ')
  end

end