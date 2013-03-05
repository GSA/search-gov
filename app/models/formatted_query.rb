class FormattedQuery
  QUERY_STRING_ALLOCATION = 1500

  attr_reader :query

  def initialize(options = {})
    @included_domains= options.delete(:included_domains) || []
    @excluded_domains= options.delete(:excluded_domains) || []
    @scope_keywords= options.delete(:scope_keywords) || []
    @site_limits= options.delete(:site_limits) || ''
  end

  protected

  def build_advanced_query(options)
    query_array = []
    query_array << remove_sites_not_in_domains(options[:query]) if options[:query].present?
    query_array << "\"#{options[:query_quote]}\"" if options[:query_quote].present?
    query_array << options[:query_not].split.map { |term| "-#{term}" }.join(' ') if options[:query_not].present?
    query_array << "(#{options[:query_or].split.join(' OR ')})" if options[:query_or].present?
    query_array << "filetype:#{options[:file_type]}" if options[:file_type].present? && options[:file_type].downcase != 'all'
    query_array << options[:site_excludes].split.map { |site| "-site:#{site}" }.join(' ') if options[:site_excludes].present?
    query_array.join(' ').squish
  end

  def includes_domain?(domain)
    @included_domains.detect { |included_domain| domain =~ /\b#{Regexp.escape(included_domain)}\b/i }
  end

  def fill_domains_to_remainder(remaining_chars, matching_site_limits = nil)
    domains, delimiter = [], " OR "
    domains_to_process = matching_site_limits.present? ? matching_site_limits : @included_domains
    domains_to_process.each do |site|
      site_str = "site:#{site}"
      break if (remaining_chars -= "#{site_str} #{delimiter}".length) < 0
      domains.unshift site_str
    end unless @included_domains.blank?
    domains.join(delimiter)
  end

  def remove_sites_not_in_domains(query)
    return query unless @included_domains.present?
    user_specified_site_limits = get_unique_domains_from_query(query)
    rejected_sites = user_specified_site_limits.reject { |s| includes_domain?(s) }
    if rejected_sites.present?
      rejected_sites_query = rejected_sites.map { |s| "site:#{s}" }
      return query.gsub(/\b(#{rejected_sites_query.join('|')})\b/i, '')
    end
    query
  end

  def get_unique_domains_from_query(query)
    query.scan(/\bsite:\S+\b/i).map { |s| s.sub(/^site:/i, '') }.uniq
  end

end