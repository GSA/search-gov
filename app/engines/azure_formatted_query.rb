class AzureFormattedQuery < FormattedQuery
  def initialize(user_query, options = {})
    super(options)
    @stripped_query = strip_site_from_query user_query
    @query = "#{@stripped_query} #{generate_domains_scope(@stripped_query)}".squish
  end

  private

  def strip_site_from_query(user_query)
    user_query.gsub(%r{-?((site:)\S+)+}i, '').squish
  end

  def generate_domains_scope(user_query)
    domains_scope = ''
    remaining_chars = QUERY_STRING_ALLOCATION - user_query.length
    domains = fill_included_domains_to_remainder(remaining_chars)
    domains_scope = "(#{domains})" if domains.present?
    excluded = fill_excluded_domains_to_remainder(remaining_chars - domains_scope.length)
    domains_scope << " (#{excluded})" if excluded.present?
    domains_scope
  end
end
