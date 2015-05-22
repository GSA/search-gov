class BingFormattedQuery < FormattedQuery
  DEFAULT_SCOPE = '(scopeid:usagovall OR site:gov OR site:mil)'

  def initialize(user_query, options = {})
    super(options)
    @scope_ids= options.delete(:scope_ids) || []
    @query = [query_plus_locale(user_query), generate_scope_and_sites(user_query)].join(' ').squish
  end

  private

  def generate_scope_and_sites(user_query)
    site_and_no_minus_site = user_query.include?('site:') && !user_query.include?('-site:')
    remaining_chars = QUERY_STRING_ALLOCATION - query_plus_locale(user_query).length
    domains = site_and_no_minus_site ? '' : fill_included_domains_to_remainder(remaining_chars)
    scope_ids_str = site_and_no_minus_site ? nil : @scope_ids.map { |scope| "scopeid:#{scope}" }.join(" OR ")
    excluded = user_query.include?('site:') ? nil : fill_excluded_domains_to_remainder(remaining_chars - domains.length)
    scope_sites = ""
    scope_sites = "(" unless scope_ids_str.blank? && domains.blank?
    scope_sites += scope_ids_str unless scope_ids_str.blank? || @matching_site_limits.present?
    scope_sites += " OR " if scope_sites.length > 1 && domains.present?
    scope_sites += domains unless domains.blank?
    scope_sites += ")" unless scope_ids_str.blank? && domains.blank?
    scope_sites += " #{DEFAULT_SCOPE}" if (scope_ids_str.blank? && domains.blank? && !user_query.include?('site:'))
    scope_sites = ['(', excluded, ') '].join + scope_sites unless excluded.blank?
    scope_sites
  end

  def query_plus_locale(user_query)
    "(#{user_query}) #{locale_if_supported}".squish
  end

  def locale_if_supported
    "language:#{I18n.locale}" if Language.exists?(code: I18n.locale, is_bing_supported: true)
  end
end