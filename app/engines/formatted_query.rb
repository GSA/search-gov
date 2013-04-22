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

  protected

  def fill_domains_to_remainder(remaining_chars)
    domains, delimiter = [], " OR "
    domains_to_process = @matching_site_limits.present? ? @matching_site_limits : @included_domains
    domains_to_process.each do |site|
      site_str = "site:#{site}"
      break if (remaining_chars -= "#{site_str} #{delimiter}".length) < 0
      domains.unshift site_str
    end unless @included_domains.blank?
    domains.join(delimiter)
  end

  private

  def included_domain_contains?(site)
    @included_domains.detect { |included_domain| site =~ /\b#{Regexp.escape(included_domain)}\b/i }
  end

end