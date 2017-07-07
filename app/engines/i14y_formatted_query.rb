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
    remaining_chars = QUERY_STRING_ALLOCATION - user_query.length
    domains = fill_included_domains_to_remainder(remaining_chars)
    excluded =  fill_excluded_domains_to_remainder(remaining_chars - domains.length)
    sites = [user_query]
    sites << excluded unless excluded.blank?
    sites << domains unless domains.blank?
    sites.join(' ')
  end
end
