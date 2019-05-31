class BingFormattedQuery < FormattedQuery
  DEFAULT_DOMAIN_SCOPE = 'site:gov OR site:mil'.freeze

  attr_reader :scope_ids

  def initialize(user_query, options = {})
    super(options)
    @stripped_query = strip_site_from_query user_query
    @scope_ids = options.delete(:scope_ids) || []
    @query = "#{@stripped_query} #{generate_scope_ids_and_domains_scope(@stripped_query)}".squish
  end

  private

  def strip_site_from_query(user_query)
    user_query = downcase_except_operators(user_query)
    user_query.gsub(%r{-?((site:)\S+)+}i, '').squish
  end

  def generate_scope_ids_and_domains_scope(user_query)
    remaining_chars = QUERY_STRING_ALLOCATION - user_query.length
    domains = fill_included_scope_ids_and_domains_to_remainder(remaining_chars)
    domains << DEFAULT_DOMAIN_SCOPE if domains.blank?
    domains_scope = "(#{domains})"
    excluded = fill_excluded_domains_to_remainder(remaining_chars - domains_scope.length)
    domains_scope << " (#{excluded})" if excluded.present?
    domains_scope
  end

  def fill_included_scope_ids_and_domains_to_remainder(remaining_chars)
    domain_terms = domains_to_process.map { |d| "site:#{d}" }
    scope_id_terms = scope_ids.map { |i| "scopeid:#{i}" }
    fill_included_terms_to_remainder(domain_terms + scope_id_terms, 'OR', remaining_chars)
  end
end
