class WebSearch < Search

  BING_CACHE_DURATION_IN_SECONDS = 60 * 60 * 6
  DEFAULT_SCOPE = "(scopeid:usagovall OR site:gov OR site:mil)"

  attr_reader :offset,
              :sources,
              :images,
              :boosted_contents,
              :filter_setting,
              :enable_highlighting,
              :agency,
              :med_topic,
              :news_items,
              :video_news_items,
              :formatted_query,
              :featured_collections,
              :indexed_documents,
              :indexed_results,
              :matching_site_limits,
              :tweets,
              :photos,
              :forms

  class << self
    def results_present_for?(query, affiliate, is_misspelling_allowed = true, filter_setting = BingSearch::DEFAULT_FILTER_SETTING)
      search = new(:query => query, :affiliate => affiliate, :filter => filter_setting)
      search.run
      spelling_ok = is_misspelling_allowed ? true : (search.spelling_suggestion.nil? or search.spelling_suggestion.fuzzily_matches?(query))
      search.results.present? && spelling_ok
    end
  end

  def initialize(options = {})
    super(options)
    @offset = (@page - 1) * @per_page
    @bing_search = BingSearch.new
    @filter_setting = BingSearch::VALID_FILTER_VALUES.include?(options[:filter] || "invalid adult filter") ? options[:filter] : BingSearch::DEFAULT_FILTER_SETTING
    @enable_highlighting = options[:enable_highlighting].nil? ? true : options[:enable_highlighting]
    @sources = "Spell+Web"
    @formatted_query = generate_formatted_query
  end

  def cache_key
    [@formatted_query, @sources, @offset, @per_page, @enable_highlighting, @filter_setting].join(':')
  end

  def has_boosted_contents?
    self.boosted_contents and self.boosted_contents.results.size > 0
  end

  def has_featured_collections?
    self.featured_collections and self.featured_collections.total > 0
  end

  def has_forms?
    self.forms and self.forms.total > 0
  end

  def are_results_by_bing?
    self.indexed_results.nil? ? true : false
  end

  protected

  def result_hash
    hash = super
    unless @error_message
      hash.merge!(:spelling_suggestion => @spelling_suggestion) if @spelling_suggestion
      hash.merge!(:boosted_results => @boosted_contents.results) if has_boosted_contents?
    end
    hash
  end

  def build_query(options)
    query = ''
    if options[:query].present?
      query += options[:query].split.collect { |term| limit_field(options[:query_limit], term) }.join(' ')
    end
    query += ' ' + limit_field(options[:query_quote_limit], "\"#{options[:query_quote]}\"") if options[:query_quote].present?
    query += ' ' + options[:query_or].split.collect { |term| limit_field(options[:query_or_limit], term) }.join(' OR ') if options[:query_or].present?
    query += ' ' + options[:query_not].split.collect { |term| "-#{limit_field(options[:query_not_limit], term)}" }.join(' ') if options[:query_not].present?
    query += " filetype:#{options[:file_type]}" unless options[:file_type].blank? || options[:file_type].downcase == 'all'
    unless options[:site_limits].blank?
      @matching_site_limits = options[:site_limits].split.collect { |site| site if options[:affiliate].includes_domain?(site) }.compact
      query += " #{self.matching_site_limits.collect { |site| "site:#{site}" }.join(' OR ')}"
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

  def search
    begin
      @affiliate.uses_odie_results? ? perform_odie_search : parse_bing_response(perform_bing_search)
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

  def parse_bing_response(response)
    @bing_search.parse_bing_response(response)
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

  def handle_response(response)
    @affiliate.uses_odie_results? ? handle_odie_response(response) : handle_bing_response(response)
  end

  def handle_odie_response(response)
    unless response.nil? and response.total > 0
      @total = response.total
      @results = response.results
      @startrecord = response.startrecord
      @endrecord = response.endrecord
    end
  end

  def handle_bing_response(response)
    @total = hits(response)
    if @total.zero?
      handle_odie_response(perform_odie_search) if self.class == WebSearch
    else
      @startrecord = bing_offset(response) + 1
      @results = paginate(process_results(response))
      @endrecord = startrecord + results.size - 1
      @spelling_suggestion = spelling_results(response)
    end
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
    news_title_descriptions_published_at = NewsItem.title_description_date_hash_by_link(response.web.results.collect(&:url))
    processed = response.web.results.collect do |result|
      title, content = extract_fields_from_news_item(result.url, news_title_descriptions_published_at)
      title ||= (result.title rescue nil)
      content ||= (result.description rescue '')
      if title.present? and not url_is_excluded(result.url)
        {
          'title' => title,
          'unescapedUrl' => result.url,
          'content' => content,
          'cacheUrl' => (result.CacheUrl rescue nil),
          'deepLinks' => result["DeepLinks"],
          'publishedAt' => (news_title_descriptions_published_at[result.url].published_at rescue nil)
        }
      else
        nil
      end
    end
    processed.compact
  end

  def url_is_excluded(url)
    parsed_url = URI::parse(url) rescue nil
    return true if parsed_url and (ExcludedDomain.excludes_host?(parsed_url.host) or @affiliate.excludes_url?(url))
    false
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

  def populate_additional_results
    super
    @boosted_contents = BoostedContent.search_for(query, affiliate)
    if first_page?
      @featured_collections = FeaturedCollection.search_for(query, affiliate)
      documents = @indexed_results.nil? ? IndexedDocument.search_for(query, affiliate, nil, 1, 3, Date.current.ago(3.months)) : nil
      if documents
        @indexed_documents = documents.hits(:verify => true)
        remove_bing_matches_from_indexed_documents
      end
      if affiliate.is_agency_govbox_enabled?
        agency_query = AgencyQuery.find_by_phrase(query)
        @agency = agency_query.agency if agency_query
      end
      govbox_enabled_feeds = affiliate.rss_feeds.govbox_enabled.to_a
      @news_items = NewsItem.search_for(query, govbox_enabled_feeds.select { |feed| !feed.is_video? }, nil, 1)
      @video_news_items = NewsItem.search_for(query, govbox_enabled_feeds.select { |feed| feed.is_video? }, nil, 1)
      @med_topic = MedTopic.search_for(query, I18n.locale.to_s) if affiliate.is_medline_govbox_enabled?
      affiliate_twitter_profiles = affiliate.twitter_profiles.collect(&:twitter_id)
      @tweets = Tweet.search_for(query, affiliate_twitter_profiles) if affiliate_twitter_profiles.any? and affiliate.is_twitter_govbox_enabled?
      @photos = FlickrPhoto.search_for(query, affiliate) if affiliate.is_photo_govbox_enabled?
      @forms = Form.search_for(query, {:form_agencies => affiliate.form_agencies.collect(&:id), :govbox_enabled => true, :count => 1}) if affiliate.form_agencies.present?
    end
  end

  def log_serp_impressions
    modules = []
    modules << (self.class.to_s == "ImageSearch" ? "IMAG" : "BWEB") unless self.total.zero?
    modules << "OVER" << "BSPEL" unless self.spelling_suggestion.nil?
    modules << "SREL" unless self.related_search.nil? or self.related_search.empty?
    modules << "NEWS" unless self.news_items.nil? or self.news_items.total.zero?
    modules << "AIDOC" unless self.indexed_documents.nil? or self.indexed_documents.empty?
    modules << "BOOS" unless self.boosted_contents.nil? or self.boosted_contents.total.zero?
    modules << "MEDL" unless self.med_topic.nil?
    modules << "TWEET" unless self.tweets.nil? or self.tweets.total.zero?
    modules << "PHOTO" unless self.photos.nil? or self.photos.total.zero?
    vertical =
      case self.class.to_s
        when "ImageSearch"
          :image
        when "WebSearch"
          :web
      end
    QueryImpression.log(vertical, affiliate.name, self.query, modules)
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
    generate_affiliate_scope
  end

  def generate_default_scope
    DEFAULT_SCOPE
  end

  def generate_affiliate_scope
    domains = (@query =~ /site:/) ? nil : fill_domains_to_remainder
    scope_ids = (@query =~ /site:/) ? nil : affiliate.scope_ids_as_array.collect { |scope| "scopeid:" + scope }.join(" OR ")
    affiliate_scope = ""
    affiliate_scope = "(" unless scope_ids.blank? and domains.blank?
    affiliate_scope += scope_ids unless scope_ids.blank?
    affiliate_scope += " OR " if affiliate_scope.length > 1 and domains.present?
    affiliate_scope += domains unless domains.blank?
    affiliate_scope += ")" unless scope_ids.blank? and domains.blank?
    affiliate_scope += " #{generate_default_scope}" if (scope_ids.blank? and domains.blank? and (@query =~ /site:/).nil?)
    affiliate_scope += " (#{affiliate.scope_keywords_as_array.collect { |keyword| "\"#{keyword}\"" }.join(" OR ")})" unless affiliate.scope_keywords.blank?
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

  def strip_extra_chars_from(did_you_mean_suggestion)
    did_you_mean_suggestion.split(/ \(scopeid/).first.gsub(/[()]/, '').gsub(/(\uE000|\uE001)/, '').gsub('-', '').strip.squish unless did_you_mean_suggestion.nil?
  end

  def remove_bing_matches_from_indexed_documents
    @indexed_documents.delete_if do |indexed_document|
      begin
        local_url_minus_slash = indexed_document.instance.url.sub(/\/$/, '')
        local_request_uri = URI.parse(local_url_minus_slash).request_uri
        local_title = indexed_document.instance.title || ''
        @results.any? do |result|
          bing_url_minus_slash = result['unescapedUrl'].sub(/\/$/, '')
          (URI.parse(bing_url_minus_slash).request_uri == local_request_uri and local_title == result['title'].gsub(/(\uE000|\uE001)/, '')) or
            bing_url_minus_slash == local_url_minus_slash
        end
      rescue URI::InvalidURIError
        false
      end
    end
  end

  def extract_fields_from_news_item(result_url, news_title_descriptions_published_at)
    @news_item_hash ||= build_news_item_hash_from_search
    news_item_hit = @news_item_hash[result_url]
    if news_item_hit.present?
      [highlight_solr_hit_like_bing(news_item_hit, :title), highlight_solr_hit_like_bing(news_item_hit, :description)]
    else
      news_item = news_title_descriptions_published_at[result_url]
      [news_item.title, news_item.description] if news_item
    end
  end

  def build_news_item_hash_from_search
    news_item_hash = {}
    news_items_overrides = NewsItem.search_for(query, affiliate.rss_feeds)
    if news_items_overrides and news_items_overrides.total > 0
      news_items_overrides.each_hit_with_result do |news_item_hit, news_item_result|
        news_item_hash[news_item_result.link] = news_item_hit
      end
    end
    news_item_hash
  end

end
