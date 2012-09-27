class SiteSearch < WebSearch
  SEPARATOR = ' OR '.freeze
  attr_reader :document_collection

  def initialize(options = {})
    @document_collection = options[:document_collection]
    super(options)
  end

  protected

  def scope
    return unless @document_collection
    remaining_chars = QUERY_STRING_ALLOCATION - query_plus_locale.length

    scope_keywords = []
    @affiliate.scope_keywords_as_array.collect { |s| "\"#{s}\"" }.each do |scope_keyword|
      separator_length = scope_keywords.empty? ? 0 : SEPARATOR.length
      remaining_chars -= (scope_keyword.length + separator_length)
      remaining_chars >= 0 ? (scope_keywords << scope_keyword) : break
    end

    sites_within_limit = []
    sites = @document_collection.url_prefixes.collect(&:prefix).collect do |prefix|
      "site:#{URI.escape(prefix.gsub(%r[(^https?://|/$)], ''))}"
    end
    sites.sort! { |a, b| a.length == b.length ? b <=> a : a.length <=> b.length }

    sites.each do |site|
      separator_length = sites_within_limit.empty? ? 0 : SEPARATOR.length
      remaining_chars -= (site.length + separator_length)
      remaining_chars >= 0 ? (sites_within_limit << site) : break
    end

    generated_scope = ''
    (generated_scope << "(#{scope_keywords.join(SEPARATOR)}) ") unless scope_keywords.empty?
    generated_scope << "(#{sites_within_limit.join(SEPARATOR)})"
    generated_scope
  end

  def populate_additional_results
  end
end