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
    domains = site_and_no_minus_site ? nil : fill_domains_to_remainder(remaining_chars)
    scope_ids_str = site_and_no_minus_site ? nil : @scope_ids.map { |scope| "scopeid:#{scope}" }.join(" OR ")
    excluded = user_query.include?('site:') ? nil : @excluded_domains.map { |ed| "-site:#{ed}" }.join(" AND ")
    scope_sites_keywords = ""
    scope_sites_keywords = "(" unless scope_ids_str.blank? && domains.blank?
    scope_sites_keywords += scope_ids_str unless scope_ids_str.blank? || @matching_site_limits.present?
    scope_sites_keywords += " OR " if scope_sites_keywords.length > 1 && domains.present?
    scope_sites_keywords += domains unless domains.blank?
    scope_sites_keywords += ")" unless scope_ids_str.blank? && domains.blank?
    scope_sites_keywords += " #{DEFAULT_SCOPE}" if (scope_ids_str.blank? && domains.blank? && !user_query.include?('site:'))
    scope_sites_keywords += " (#{@scope_keywords.collect { |keyword| "\"#{keyword}\"" }.join(" OR ")})" unless @scope_keywords.blank?
    scope_sites_keywords = ['(', excluded, ') '].join + scope_sites_keywords unless excluded.blank?
    scope_sites_keywords
  end

  def query_plus_locale(user_query)
    "(#{user_query}) #{non_english_locale}".squish
  end

  def non_english_locale
    "language:#{I18n.locale}" if I18n.locale.to_s != 'en'
  end
end