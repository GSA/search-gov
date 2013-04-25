class FormattedQuery
  QUERY_STRING_ALLOCATION = 1500
  attr_reader :query,
              :matching_site_limits

  def initialize(options = {})
    @included_domains= options.delete(:included_domains) || []
    @excluded_domains= options.delete(:excluded_domains) || []
    @scope_keywords= options.delete(:scope_keywords) || []
    site_limits= options.delete(:site_limits) || ''
    @matching_site_limits = site_limits.split.select { |site| included_domain_contains?(site) }
  end

  private

  def included_domain_contains?(site)
    @included_domains.detect { |included_domain| site =~ /\b#{Regexp.escape(included_domain)}\b/i }
  end

end