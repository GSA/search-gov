class Search
  class BingSearchError < RuntimeError;
  end

  @@redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)

  BING_CACHE_DURATION_IN_SECONDS = 60 * 60 * 6
  MAX_QUERY_LENGTH_FOR_ITERATIVE_SEARCH = 30
  MAX_QUERYTERM_LENGTH = 1000
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 50
  JSON_SITE = "http://api.bing.net/json.aspx"
  APP_ID = "A4C32FAE6F3DB386FC32ED1C4F3024742ED30906"
  USER_AGENT = "USASearch"
  DEFAULT_SCOPE = "(scopeid:usagovall OR site:gov OR site:mil)"
  VALID_FILTER_VALUES = %w{off moderate strict}
  DEFAULT_FILTER_SETTING = 'moderate'
  URI_REGEX = Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
  QUERY_STRING_ALLOCATION = 1800

  attr_reader :query,
              :page,
              :error_message,
              :affiliate,
              :total,
              :results,
              :sources,
              :extra_image_results,
              :startrecord,
              :endrecord,
              :images,
              :related_search,
              :spelling_suggestion,
              :boosted_contents,
              :faqs,
              :recalls,
              :results_per_page,
              :offset,
              :filter_setting,
              :fedstates,
              :queried_at_seconds,
              :enable_highlighting,
              :agency,
              :med_topic,
              :formatted_query,
              :featured_collections,
              :indexed_documents,
              :indexed_results,
              :matching_site_limit

  def initialize(options = {})
    options ||= {}
    @query = build_query(options)
    @site_limits = options[:site_limits]
    @affiliate = options[:affiliate]
    @matching_site_limit = retrieve_matching_site_limit
    @page = [options[:page].to_i, 0].max
    @results_per_page = options[:results_per_page] || DEFAULT_PER_PAGE
    @results_per_page = @results_per_page.to_i unless @results_per_page.is_a?(Integer)
    @results_per_page = [@results_per_page, MAX_PER_PAGE].min
    @offset = @page * @results_per_page
    @fedstates = options[:fedstates] || nil
    @filter_setting = VALID_FILTER_VALUES.include?(options[:filter] || "invalid adult filter") ? options[:filter] : DEFAULT_FILTER_SETTING
    @results, @related_search = [], []
    @queried_at_seconds = Time.now.to_i
    @enable_highlighting = options[:enable_highlighting].nil? ? true : options[:enable_highlighting]
    @sources = bing_sources
    @formatted_query = generate_formatted_query
  end

  def run
    @error_message = (I18n.translate :too_long) and return false if query.length > MAX_QUERYTERM_LENGTH
    @error_message = (I18n.translate :empty_query) and return false if query.blank?

    begin
      response = parse(perform)
    rescue BingSearchError => error
      Rails.logger.warn "Error getting search results from Bing server: #{error}"
      return false
    end

    @total = hits(response)
    if total.zero?
      if @affiliate and self.class == Search
        @indexed_results = IndexedDocument.search_for(query, affiliate, page + 1, 10)
        unless @indexed_results.nil?
          @total = @indexed_results.total
          @startrecord = (page * 10) + 1
          @results = paginate(process_indexed_results(@indexed_results))
          @endrecord = startrecord + @results.size - 1
        end
      end
    else
      @startrecord = bing_offset(response) + 1
      @page = [startrecord/10, page].min
      @results = paginate(process_results(response))
      @endrecord = startrecord + results.size - 1
      @spelling_suggestion = spelling_results(response)
      @related_search = related_search_results
    end
    populate_additional_results(response)
    log_serp_impressions
    true
  end

  def related_search_results
    SaytSuggestion.related_search(@query, @affiliate)
  end

  def has_related_searches?
    @related_search && @related_search.size > 0
  end

  def as_json(options = {})
    if error_message
      {:error => error_message}
    else
      {:total => total,
       :startrecord => startrecord,
       :endrecord => endrecord,
       :spelling_suggestions => spelling_suggestion,
       :related => remove_strong(related_search),
       :results => results,
       :boosted_results => boosted_contents.try(:results)}
    end
  end

  def to_xml(options = {:indent => 0, :root => :search})
    if error_message
      {:error => error_message}.to_xml(options)
    else
      {:total => total,
       :startrecord => startrecord,
       :endrecord => endrecord,
       :spelling_suggestions => spelling_suggestion,
       :related_searches => related_search,
       :results => results,
       :boosted_results => boosted_contents.try(:results)}.to_xml(options)
    end
  end

  def self.suggestions(affiliate_id, sanitized_query, num_suggestions = 15)
    corrected_query = Misspelling.correct(sanitized_query)
    suggestions = SaytSuggestion.like(affiliate_id, corrected_query, num_suggestions) || []
    suggestions[0, num_suggestions]
  end

  def self.results_present_for?(query, affiliate, is_misspelling_allowed = true, filter_setting = DEFAULT_FILTER_SETTING)
    search = new(:query => query, :affiliate => affiliate, :filter_setting => filter_setting)
    search.run
    spelling_ok = is_misspelling_allowed ? true : (search.spelling_suggestion.nil? or search.spelling_suggestion.fuzzily_matches?(query))
    return (search.results.present? && spelling_ok)
  end

  def bing_sources
    query_for_images = page < 1 && affiliate.nil? && PopularImageQuery.find_by_query(query).present?
    query_for_images ? "Spell+Web+Image" : "Spell+Web"
  end

  def cache_key
    [formatted_query, sources, offset, results_per_page, enable_highlighting, filter_setting].join(':')
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

  def spelling_results(response)
    did_you_mean_suggestion = response.spell.results.first.value rescue nil
    cleaned_suggestion_without_bing_highlights = strip_extra_chars_from(did_you_mean_suggestion)
    cleaned_query = strip_extra_chars_from(@query)
    cleaned_suggestion_without_bing_highlights == cleaned_query ? nil : cleaned_suggestion_without_bing_highlights
  end

  def populate_additional_results(response)
    @boosted_contents = BoostedContent.search_for(query, affiliate, I18n.locale)
    if first_page?
      @featured_collections = FeaturedCollection.search_for(query, affiliate, I18n.locale)
      documents = (affiliate and @indexed_results.nil?) ? IndexedDocument.search_for(query, affiliate) : nil
      if documents
        @indexed_documents = documents.hits(:verify => true)
        remove_bing_matches_from_indexed_documents
      end
    end
    unless affiliate
      @faqs = Faq.search_for(query, I18n.locale.to_s)
      if first_page?
        @recalls = Recall.recent(query)
        agency_query = AgencyQuery.find_by_phrase(query)
        @agency = agency_query.agency if agency_query
        @med_topic = MedTopic.search_for(query, I18n.locale.to_s)
      end
    end
    if response && response.has?(:image) && response.image.total > 0
      @extra_image_results = process_image_results(response)
    end
  end

  def paginate(items)
    pagination_total = [results_per_page * 100, total].min
    WillPaginate::Collection.create(page + 1, results_per_page, pagination_total) { |pager| pager.replace(items) }
  end

  def perform
    response_body = @@redis.get(cache_key) rescue nil
    return response_body unless response_body.nil?
    ActiveSupport::Notifications.instrument("bing_search.usasearch", :query => {:term => formatted_query}) do
      begin
        uri = URI.parse(bing_query(formatted_query, sources, offset, results_per_page, enable_highlighting))
        Rails.logger.debug("URI to Bing: #{uri}")
        http = Net::HTTP.new(uri.host, uri.port)
        req = Net::HTTP::Get.new(uri.request_uri)
        req["User-Agent"] = USER_AGENT

        response = http.request(req)
        @@redis.setex(cache_key, BING_CACHE_DURATION_IN_SECONDS, response.body) rescue nil
        response.body
      rescue SocketError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ENETUNREACH, Errno::EHOSTUNREACH, Timeout::Error, EOFError, Errno::ETIMEDOUT => error
        raise BingSearchError.new(error.to_s)
      end
    end
  end

  def parse(response_body)
    begin
      json = JSON.parse(response_body)
      ResponseData.new(json['SearchResponse']) unless json.nil?
    rescue JSON::ParserError => error
      raise BingSearchError.new(error.to_s)
    end
  end

  def build_query(options)
    query = ''
    if options[:query].present?
      options[:query].downcase! if options[:query][-3, options[:query].size] == " OR"
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
    query += " #{options[:site_limits].split.collect { |site| 'site:' + site }.join(' OR ')}" unless options[:site_limits].blank? or options[:affiliate]
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

  def retrieve_matching_site_limit
    @site_limits.strip if I18n.locale == :en and @affiliate and @site_limits.present? and @site_limits.split.size == 1 and @affiliate.get_matching_domain(@site_limits).present?
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

  def generate_affiliate_scope
    domains = fill_domains_to_remainder unless query =~ /site:/
    scopes = affiliate.scope_ids_as_array.collect { |scope| "scopeid:" + scope }.join(" OR ")
    affiliate_scope = ""
    affiliate_scope = "(" unless scopes.blank? and domains.blank?
    affiliate_scope += scopes
    affiliate_scope += " OR " if affiliate_scope.length > 1 and domains.present?
    affiliate_scope += domains unless domains.blank?
    affiliate_scope += ")" unless scopes.blank? and domains.blank?
    affiliate_scope += " #{generate_default_scope}" if (query =~ /site:/ and scopes.blank?) or (scopes.blank? and domains.blank?)
    affiliate_scope.strip
  end

  def generate_default_scope
    DEFAULT_SCOPE
  end

  def query_plus_locale
    "(#{query}) #{locale}".strip.squeeze(' ')
  end

  def fill_domains_to_remainder
    return "site:#{@matching_site_limit}" unless @matching_site_limit.blank?
    remaining_chars = QUERY_STRING_ALLOCATION - query_plus_locale.length
    domains, delimiter = [], " OR "
    affiliate.domains.split.each do |site|
      site_str = "site:#{site}"
      encoded_str = URI.escape(site_str + delimiter, URI_REGEX)
      break if (remaining_chars -= encoded_str.length) < 0
      domains << site_str
    end if affiliate.domains
    "#{domains.join(delimiter)}"
  end

  private

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
        when "Search"
          :web
      end
    QueryImpression.log(vertical, affiliate.nil? ? Affiliate::USAGOV_AFFILIATE_NAME : affiliate.name, self.query, modules)
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

  def process_web_results(response)
    processed = response.web.results.collect do |result|
      title = result.title rescue nil
      content = result.description rescue ''
      if title.present? and not url_is_excluded(result.url)
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
    processed.compact
  end

  def url_is_excluded(url)
    parsed_url = URI::parse(url) rescue nil
    return true if parsed_url and ExcludedDomain.all.any? { |excluded_domain| parsed_url.host.ends_with(excluded_domain.domain) }
    @affiliate ? @affiliate.excluded_urls.any? { |excluded_url| url.match(excluded_url.url) } : false
  end

  def process_indexed_results(indexed_results)
    processed = indexed_results.hits.collect do |hit|
      {
        'title' => highlight_solr_hit_like_bing(hit, :title),
        'unescapedUrl' => hit.instance.url,
        'content' => highlight_solr_hit_like_bing(hit, :description),
        'cacheUrl' => nil,
        'deepLinks' => nil
      }
    end
    processed.compact
  end

  def bing_query(query_string, query_sources, offset, count, enable_highlighting = true)
    params = [
      "web.offset=#{offset}",
      "web.count=#{count}",
      "AppId=#{APP_ID}",
      "sources=#{query_sources}",
      "Options=#{ enable_highlighting ? "EnableHighlighting" : ""}",
      "Adult=#{filter_setting}",
      "query=#{URI.escape(query_string, URI_REGEX)}"
    ]
    "#{JSON_SITE}?" + params.join('&')
  end

  def strip_extra_chars_from(did_you_mean_suggestion)
    did_you_mean_suggestion.split(/ \(scopeid/).first.gsub(/[()]/, '').gsub(/\xEE\x80(\x80|\x81)/, '').gsub('-', '').strip.squish unless did_you_mean_suggestion.nil?
  end

  def first_page?
    page == 0
  end

  def highlight_solr_hit_like_bing(hit, field_symbol)
    return hit.highlights(field_symbol).first.format { |phrase| "\xEE\x80\x80#{phrase}\xEE\x80\x81" } unless hit.highlights(field_symbol).first.nil?
    hit.instance.send(field_symbol)
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
end