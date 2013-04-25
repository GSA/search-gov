class AdvancedQueryBuilder
  def initialize(included_domains, query_options)
    @included_domains = included_domains
    @options = query_options
  end

  def build
    query_array = []
    query_array << remove_sites_not_in_domains(@options[:query]) if @options[:query].present?
    query_array << "\"#{@options[:query_quote]}\"" if @options[:query_quote].present?
    query_array << @options[:query_not].split.map { |term| "-#{term}" }.join(' ') if @options[:query_not].present?
    query_array << "(#{@options[:query_or].split.join(' OR ')})" if @options[:query_or].present?
    query_array << "filetype:#{@options[:file_type]}" if @options[:file_type].present? && @options[:file_type].downcase != 'all'
    query_array << @options[:site_excludes].split.map { |site| "-site:#{site}" }.join(' ') if @options[:site_excludes].present?
    query_array.join(' ').squish
  end

  private
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

  def includes_domain?(domain)
    @included_domains.detect { |included_domain| domain =~ /\b#{Regexp.escape(included_domain)}\b/i }
  end

end