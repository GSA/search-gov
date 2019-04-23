class I14yFormattedQuery < FormattedQuery
  def initialize(user_query, options = {})
    super(options)
    @query = query_with_sites(user_query)
  end

  private

  def delimiters
    { inclusion: '', exclusion: '' }
  end

  def query_with_sites(user_query)
    site_no_minus_site = user_query.include?('site:') &&
                         !user_query.include?('-site:')
    current_chars = QUERY_STRING_ALLOCATION - user_query.length
    domains = site_no_minus_site ? '' : fill_included_domains_to_remainder(current_chars)
    excluded = fill_excluded_domains_to_remainder(current_chars - domains.length)
    get_sites(user_query, excluded, domains)
  end

  def get_sites(user_query, excluded, domains)
    sites = [user_query]
    sites << excluded if excluded.present?
    sites << domains if domains.present?
    sites.join(' ')
  end
end
