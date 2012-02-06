class WebSearch < Search

  BING_CACHE_DURATION_IN_SECONDS = 60 * 60 * 6
  DEFAULT_SCOPE = "(scopeid:usagovall OR site:gov OR site:mil)"

  attr_reader :offset,
              :sources,
              :extra_image_results,
              :images,
              :related_search,
              :spelling_suggestion,
              :boosted_contents,
              :faqs,
              :recalls,
              :filter_setting,
              :fedstates,
              :enable_highlighting,
              :agency,
              :med_topic,
              :formatted_query,
              :featured_collections,
              :indexed_documents,
              :indexed_results,
              :matching_site_limit

  class << self
    def suggestions(affiliate_id, sanitized_query, num_suggestions = 15)
      corrected_query = Misspelling.correct(sanitized_query)
      suggestions = SaytSuggestion.like(affiliate_id, corrected_query, num_suggestions) || []
      suggestions[0, num_suggestions]
    end

    def results_present_for?(query, affiliate, is_misspelling_allowed = true, filter_setting = BingSearch::DEFAULT_FILTER_SETTING)
      search = new(:query => query, :affiliate => affiliate, :filter_setting => filter_setting)
      search.run
      spelling_ok = is_misspelling_allowed ? true : (search.spelling_suggestion.nil? or search.spelling_suggestion.fuzzily_matches?(query))
      search.results.present? && spelling_ok
    end
  end

  def initialize(options = {})
    super(options)
    @offset = (@page - 1) * @per_page
    @fedstates = options[:fedstates] || nil

    @bing_search = BingSearch.new(USER_AGENT)
    @filter_setting = BingSearch::VALID_FILTER_VALUES.include?(options[:filter] || "invalid adult filter") ? options[:filter] : BingSearch::DEFAULT_FILTER_SETTING
    @enable_highlighting = options[:enable_highlighting].nil? ? true : options[:enable_highlighting]
    @sources = bing_sources
    @formatted_query = generate_formatted_query

    @related_search = []
  end

  def cache_key
    [@formatted_query, @sources, @offset, @per_page, @enable_highlighting, @filter_setting].join(':')
  end

  def as_json(options = {})
    if @error_message
      {:error => @error_message}
    else
      {:total => @total,
       :startrecord => @startrecord,
       :endrecord => @endrecord,
       :spelling_suggestions => @spelling_suggestion,
       :related => remove_strong(@related_search),
       :results => @results,
       :boosted_results => @boosted_contents.try(:results)}
    end
  end

  def to_xml(options = {:indent => 0, :root => :search})
    if error_message
      {:error => error_message}.to_xml(options)
    else
      {:total => @total,
       :startrecord => @startrecord,
       :endrecord => @endrecord,
       :spelling_suggestions => @spelling_suggestion,
       :related_searches => @related_search,
       :results => @results,
       :boosted_results => @boosted_contents.try(:results)}.to_xml(options)
    end
  end

  def has_related_searches?
    @related_search && @related_search.size > 0
  end

  def has_boosted_contents?
    self.boosted_contents and self.boosted_contents.total > 0
  end

  def has_featured_collections?
    self.featured_collections and self.featured_collections.total > 0
  end

  def are_results_by_bing?
    self.indexed_results.nil? ? true : false
  end

  protected

  def build_query(options)
    query = ''
    if options[:query].present?
      options[:query].downcase! if options[:query].ends_with? " OR"
      query += options[:query].split.collect { |term| limit_field(options[:query_limit], term) }.join(' ')
    end

    if options[:query_quote].present?
      query += ' ' + limit_field(options[:query_quote_limit], "\"#{options[:query_quote]}\"")
    end

    if options[:query_or].present?
      query += ' ' + options[:query_or].split.collect { |term| limit_field(options[:query_or_limit], term) }.join(' OR ')
    end

    if options[:query_not].present?
      query += ' ' + options[:query_not].split.collect { |term| "-#{limit_field(options[:query_not_limit], term)}" }.join(' ')
    end
    query += " filetype:#{options[:file_type]}" unless options[:file_type].blank? || options[:file_type].downcase == 'all'
    if options[:affiliate]
      query += " #{options[:site_limits].split.collect { |site| 'site:' + site if options[:affiliate].includes_domain?(site) }.join(' OR ')}" unless options[:site_limits].blank?
    else
      query += " #{options[:site_limits].split.collect { |site| 'site:' + site }.join(' OR ')}" unless options[:site_limits].blank?
    end
    query += " #{options[:site_excludes].split.collect { |site| '-site:' + site }.join(' ')}" unless options[:site_excludes].blank?
    query.strip
  end

  def limit_field(field_name, term)
    if field_name.blank?
      term
    else
      "#{field_name}#{term}"
    end
  end

  def bing_sources
    query_for_images = first_page? && affiliate.nil? && PopularImageQuery.find_by_query(query).present?
    query_for_images ? "Spell+Web+Image" : "Spell+Web"
  end

  def search
    begin
      if @affiliate and @affiliate.uses_odie_results?
        perform_odie_search
      else
        parse_bing_response(perform_bing_search)
      end
    rescue BingSearch::BingSearchError => error
      Rails.logger.warn "Error getting search results from Bing server: #{error}"
      false
    end
  end

  def perform_odie_search
    odie_search = OdieSearch.new(@options)
    odie_search.run
    @indexed_results = odie_search
  end

  def perform_bing_search
    response_body = @@redis.get(cache_key) rescue nil
    return response_body unless response_body.nil?
    ActiveSupport::Notifications.instrument("bing_search.usasearch", :query => {:term => @formatted_query}) do
      response = @bing_search.query(@formatted_query, @sources, @offset, @per_page, @enable_highlighting, @filter_setting)
      @@redis.setex(cache_key, BING_CACHE_DURATION_IN_SECONDS, response) rescue nil
      response
    end
  end

  def parse_bing_response(response_body)
    begin
      json = JSON.parse(response_body)
      json.nil? ? nil : ResponseData.new(json['SearchResponse'])
    rescue JSON::ParserError => error
      raise BingSearch::BingSearchError.new(error.to_s)
    end
  end

  def handle_response(response)
    if @affiliate and @affiliate.uses_odie_results?
      handle_odie_response(response)
    else
      handle_bing_response(response)
    end
  end

  def handle_odie_response(response)
    unless response.nil? and response.total > 0
      @total = response.total
      @startrecord = response.startrecord
      @results = response.results
      @endrecord = response.endrecord
    end
  end

  def handle_bing_response(response)
    @total = hits(response)
    if @total.zero?
      if @affiliate and self.class == WebSearch
        handle_odie_response(perform_odie_search)
      end
    else
      @startrecord = bing_offset(response) + 1
      @results = paginate(process_results(response))
      @endrecord = startrecord + results.size - 1
      @spelling_suggestion = spelling_results(response)
    end
    @related_search = related_search_results
  end

  def hits(response)
    (response.web.results.blank? ? 0 : response.web.total) rescue 0
  end

  def bing_offset(response)
    (response.web.results.blank? ? 0 : response.web.offset) rescue 0
  end

  def process_results(response)
    process_web_results(response)
  end

  def process_web_results(response)
    synonyms = []
    processed = response.web.results.collect do |result|
      title = result.title rescue nil
      content = result.description rescue ''
      if title.present? and not url_is_excluded(result.url)
        synonyms = synonyms + parse_synonyms(@query, title, content)
        {
          'title' => title,
          'unescapedUrl' => result.url,
          'content' => content,
          'cacheUrl' => (result.CacheUrl rescue nil),
          'deepLinks' => result["DeepLinks"]
        }
      else
        nil
      end
    end
    synonyms.uniq.each{|synonym| Synonym.create(:phrase => @query.downcase, :alias => synonym, :source => 'bing')}
    processed.compact
  end

  def process_image_results(response)
    response.image.results.collect do |result|
      {
        "title" => result.title,
        "Width" => result.width,
        "Height" => result.height,
        "FileSize" => result.fileSize,
        "ContentType" => result.contentType,
        "Url" => result.Url,
        "DisplayUrl" => result.displayUrl,
        "MediaUrl" => result.mediaUrl,
        "Thumbnail" => {
          "Url" => result.thumbnail.url,
          "FileSize" => result.thumbnail.fileSize,
          "Width" => result.thumbnail.width,
          "Height" => result.thumbnail.height,
          "ContentType" => result.thumbnail.contentType
        }
      }
    end
  end

  def spelling_results(response)
    did_you_mean_suggestion = response.spell.results.first.value rescue nil
    cleaned_suggestion_without_bing_highlights = strip_extra_chars_from(did_you_mean_suggestion)
    cleaned_query = strip_extra_chars_from(@query)
    cleaned_suggestion_without_bing_highlights == cleaned_query ? nil : cleaned_suggestion_without_bing_highlights
  end

  def related_search_results
    SaytSuggestion.related_search(@query, @affiliate)
  end

  def populate_additional_results(response)
    @boosted_contents = BoostedContent.search_for(query, affiliate, I18n.locale)
    @faqs = Faq.search_for(query, I18n.locale.to_s) unless affiliate
    if first_page?
      @featured_collections = FeaturedCollection.search_for(query, affiliate, I18n.locale)
      documents = (affiliate and @indexed_results.nil?) ? IndexedDocument.search_for(query, affiliate) : nil
      if documents
        @indexed_documents = documents.hits(:verify => true)
        remove_bing_matches_from_indexed_documents
      end
      if affiliate.nil? or (affiliate and affiliate.is_agency_govbox_enabled?)
        agency_query = AgencyQuery.find_by_phrase(query)
        @agency = agency_query.agency if agency_query
      end
      @med_topic = MedTopic.search_for(query, I18n.locale.to_s) if affiliate.nil? or (affiliate and affiliate.is_medline_govbox_enabled?)
      @recalls = Recall.recent(query) unless affiliate
    end
    if response && response.is_a?(Hash) && response.has?(:image) && response.image.total > 0
      @extra_image_results = process_image_results(response)
    end
  end

  def log_serp_impressions
    modules = []
    modules << (self.class.to_s == "ImageSearch" ? "IMAG" : "BWEB") unless self.total.zero?
    modules << "IMAG" unless self.class.to_s == "ImageSearch" or self.extra_image_results.nil?
    modules << "OVER" << "BSPEL" unless self.spelling_suggestion.nil?
    modules << "SREL" unless self.related_search.nil? or self.related_search.empty?
    modules << "FAQS" unless self.faqs.nil? or self.faqs.total.zero?
    modules << "RECALL" unless self.recalls.nil?
    modules << "BOOS" unless self.boosted_contents.nil? or self.boosted_contents.total.zero?
    modules << "MEDL" unless self.med_topic.nil?
    vertical =
      case self.class.to_s
        when "ImageSearch"
          :image
        when "FormSearch"
          :form
        when "WebSearch"
          :web
      end
    QueryImpression.log(vertical, affiliate.nil? ? Affiliate::USAGOV_AFFILIATE_NAME : affiliate.name, self.query, modules)
  end

  def english_locale?
    I18n.locale.to_s == 'en'
  end

  def locale
    return if english_locale?
    "language:#{I18n.locale}"
  end

  def generate_formatted_query
    [query_plus_locale, scope].join(' ').strip
  end

  def query_plus_locale
    "(#{query}) #{locale}".strip.squeeze(' ')
  end

  def scope
    if affiliate
      generate_affiliate_scope
    else
      if self.fedstates && !self.fedstates.empty? && self.fedstates != 'all'
        "(scopeid:usagov#{self.fedstates})"
      else
        generate_default_scope
      end
    end
  end

  def generate_default_scope
    DEFAULT_SCOPE
  end

  def generate_affiliate_scope
    domains = (@query =~ /site:/) ? nil : fill_domains_to_remainder
    scope_ids = affiliate.scope_ids_as_array.collect { |scope| "scopeid:" + scope }.join(" OR ")
    affiliate_scope = ""
    affiliate_scope = "(" unless scope_ids.blank? and domains.blank?
    affiliate_scope += scope_ids
    affiliate_scope += " OR " if affiliate_scope.length > 1 and domains.present?
    affiliate_scope += domains unless domains.blank?
    affiliate_scope += ")" unless scope_ids.blank? and domains.blank?
    affiliate_scope += " #{generate_default_scope}" if (scope_ids.blank? and domains.blank? and (@query =~ /site:/).nil?)
    affiliate_scope += " (#{affiliate.scope_keywords_as_array.collect{|keyword| "\"#{keyword}\""}.join(" OR ")})" unless affiliate.scope_keywords.blank?
    affiliate_scope.strip
  end

  def fill_domains_to_remainder
    remaining_chars = QUERY_STRING_ALLOCATION - query_plus_locale.length
    domains, delimiter = [], " OR "
    affiliate.domains_as_array.each do |site|
      site_str = "site:#{site}"
      encoded_str = URI.escape(site_str + delimiter, URI_REGEX)
      break if (remaining_chars -= encoded_str.length) < 0
      domains << site_str
    end unless affiliate.domains_as_array.blank?
    "#{domains.join(delimiter)}"
  end

  def url_is_excluded(url)
    parsed_url = URI::parse(url) rescue nil
    return true if parsed_url and ExcludedDomain.all.any? { |excluded_domain| parsed_url.host.ends_with(excluded_domain.domain) }
    @affiliate ? @affiliate.excluded_urls.any? { |excluded_url| url.match(excluded_url.url) } : false
  end

  def strip_extra_chars_from(did_you_mean_suggestion)
    did_you_mean_suggestion.split(/ \(scopeid/).first.gsub(/[()]/, '').gsub(/\xEE\x80(\x80|\x81)/, '').gsub('-', '').strip.squish unless did_you_mean_suggestion.nil?
  end

  def remove_bing_matches_from_indexed_documents
    @indexed_documents.delete_if do |indexed_document|
      begin
        local_url_minus_slash = indexed_document.instance.url.sub(/\/$/, '')
        local_request_uri = URI.parse(local_url_minus_slash).request_uri
        local_title = indexed_document.instance.title || ''
        @results.any? do |result|
          bing_url_minus_slash = result['unescapedUrl'].sub(/\/$/, '')
          (URI.parse(bing_url_minus_slash).request_uri == local_request_uri and local_title == result['title'].gsub(/\xEE\x80(\x80|\x81)/, '')) or
            bing_url_minus_slash == local_url_minus_slash
        end
      rescue URI::InvalidURIError
        false
      end
    end
  end

  def remove_strong(string_array)
    string_array.map { |entry| entry.gsub(/<\/?strong>/, '') } if string_array.kind_of?(Array)
  end
  
  def parse_synonyms(query, title, content)
    matches = title.scan(/\xEE\x80\x80.*?\xEE\x80\x81/) + content.scan(/\xEE\x80\x80.*?\xEE\x80\x81/)
    synonyms = matches.collect do |alias_phrase|
      alias_phrase.gsub!(/\xEE\x80\x80/, '').gsub!(/\xEE\x80\x81/, '').downcase!
      alias_phrase unless query.downcase == alias_phrase
    end
    synonyms.compact
  end
end