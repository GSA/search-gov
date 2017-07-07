class FormattedQuery
  QUERY_STRING_ALLOCATION = 1500
  SEARCH_OPERATORS = %w{ AND OR NOT NEAR }
  attr_reader :query,
              :matching_site_limits

  def initialize(options = {})
    @included_domains= options.delete(:included_domains) || []
    @excluded_domains= options.delete(:excluded_domains) || []
    site_limits= options.delete(:site_limits) || ''
    @matching_site_limits = site_limits.split.select { |site| included_domain_contains?(site) }
  end

  def domains_to_process
    @matching_site_limits.present? ? @matching_site_limits : @included_domains
  end

  protected

  def fill_included_domains_to_remainder(remaining_chars)
    terms = @included_domains.blank? ? [] : domains_to_process.map { |d| "site:#{d}" }
    fill_included_terms_to_remainder(terms, delimiters[:inclusion], remaining_chars)
  end

  def fill_excluded_domains_to_remainder(remaining_chars)
    terms = @excluded_domains.map { |d| "-site:#{d}" }
    fill_included_terms_to_remainder(terms, delimiters[:exclusion], remaining_chars)
  end

  def fill_included_terms_to_remainder(terms, delimiter, remaining_chars)
    included_terms = []
    padded_delimiter = " #{delimiter} ".squeeze(' ')
    terms.each do |term|
      break if (remaining_chars -= "#{term} #{padded_delimiter}".length) < 0
      included_terms.unshift term
    end
    included_terms.join(padded_delimiter)
  end

  private

  def included_domain_contains?(site)
    @included_domains.detect { |included_domain| site =~ /\b#{Regexp.escape(included_domain)}\b/i }
  end

  def downcase_except_operators(query)
    query.split(' ').map { |word|
      SEARCH_OPERATORS.include?(word) ? word : word.downcase
    }.join(' ')
  end

  def delimiters
    { inclusion: 'OR', exclusion: 'AND' }
  end
end
