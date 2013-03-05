class WebSearch < Search
  DEFAULT_SEARCH_ENGINE_OPTION = 'Bing'

  attr_reader :sources,
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
              :forms,
              :jobs
              #:search_engine

  class << self
    #TODO: move to BingSearch
    def results_present_for?(query, affiliate, is_misspelling_allowed = true, filter_setting = BingSearch::DEFAULT_FILTER_SETTING)
      search = new(:query => query, :affiliate => affiliate, :filter => filter_setting)
      search.run
      spelling_ok = is_misspelling_allowed ? true : (search.spelling_suggestion.nil? or search.spelling_suggestion.fuzzily_matches?(query))
      search.results.present? && spelling_ok
    end
  end

  def initialize(options = {})
    super(options)
    offset = (page - 1) * per_page + 1
    search_engine_option = @affiliate.present? ? @affiliate.search_engine : DEFAULT_SEARCH_ENGINE_OPTION
    formatted_query_klass = "#{search_engine_option}FormattedQuery"
    search_engine_klass = "#{search_engine_option}Search"
    formatted_query = formatted_query_klass.constantize.new(options)
    @search_engine = search_engine_klass.constantize.new(options.merge(query: formatted_query.query, offset: offset))
  end

  def has_boosted_contents?
    self.boosted_contents and self.boosted_contents.results.size > 0
  end

  def has_featured_collections?
    self.featured_collections and self.featured_collections.total > 0
  end

  def has_forms?
    forms and forms.total > 0
  end

  #TODO: used by helpers and for logging module name
  def are_results_by_bing?
    self.indexed_results.nil?
  end

  def qualify_for_form_fulltext_search?
    query =~ /[[:digit:]]/i or query =~ /\bforms?\b/i && query.gsub(/\bforms?\b/i, '').strip.present?
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

  def search
    ActiveSupport::Notifications.instrument("#{@search_engine.class.name.tableize.singularize}.usasearch", :query => {:term => @search_engine.query}) do
      @search_engine.execute_query
    end
  rescue SearchEngine::SearchError => error
    Rails.logger.warn "Error getting search results from #{@search_engine.class.name} API endpoint: #{error}"
    false
  end

  def handle_response(response)
    @total = response.total
    available_search_engine_pages = (@total/@per_page.to_f).ceil
    if backfill_needed?
      odie_search = odie_search_class.new(@options.merge(:page => [@page - available_search_engine_pages, 1].max))
      odie_response = odie_search.search
      if odie_response and odie_response.total > 0
        adjusted_total = available_search_engine_pages * @per_page + odie_response.total
        if @total <= @per_page * (@page - 1) and available_search_engine_pages < @page
          temp_total = @total
          @total = adjusted_total
          @results = paginate(odie_search.process_results(odie_response))
          @total = temp_total
          @startrecord = (@page -1) * @per_page + 1
          @endrecord = @startrecord + odie_response.results.size - 1
          @indexed_results = odie_response
        end
        @total = adjusted_total
      end
    end
    handle_search_engine_response(response) if available_search_engine_pages >= @page
    assign_module_tag
  end

  def handle_search_engine_response(response)
    @startrecord = response.start_record
    #TODO: process_web_results to handle news/excludes
    @results = paginate(response.results)
    @endrecord = response.end_record
    @spelling_suggestion = response.spelling_suggestion
  end

  def backfill_needed?
    @total < @per_page * @page
  end

  def assign_module_tag
    if @total > 0
      #TODO: module name
      @module_tag = are_results_by_bing? ? 'BWEB' : 'AIDOC'
    else
      @module_tag = nil
    end
  end

  def process_web_results(response)
    news_title_descriptions_published_at = NewsItem.title_description_date_hash_by_link(@affiliate, response.web.results.collect(&:url))
    excluded_urls_empty = @affiliate.excluded_urls.empty?
    processed = response.web.results.collect do |result|
      title, content = extract_fields_from_news_item(result.url, news_title_descriptions_published_at)
      title ||= (result.title rescue nil)
      content ||= result.description || ''
      if title.present? && (excluded_urls_empty || !url_is_excluded(result.url))
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
    return true if parsed_url and @affiliate.excludes_url?(url)
    false
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

  #TODO: WhyTF is this here and not in ImageSearch?
  def process_image_results(response)
    processed = response.image.results.collect do |result|
      begin
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
      rescue NoMethodError => e
        nil
      end
    end
    processed.compact
  end

  def populate_additional_results
    super
    #TODO: just curious, what does 'query' look like when there are excluded domains, etc?
    #TODO: put in GovBox.rb
    if first_page?
      @boosted_contents = BoostedContent.search_for(query, affiliate)
      @featured_collections = FeaturedCollection.search_for(query, affiliate)
      if affiliate.is_agency_govbox_enabled?
        agency_query = AgencyQuery.find_by_phrase(query)
        @agency = agency_query.agency if agency_query
      end
      if affiliate.jobs_enabled?
        jobs_options = {query: query, size: 3, hl: 1, geoip_info: geoip_info}
        jobs_options.merge!(organization_id: affiliate.agency.organization_code) if affiliate.has_organization_code?
        @jobs = Usajobs.search(jobs_options)
      end
      govbox_enabled_feeds = affiliate.rss_feeds.govbox_enabled.to_a
      @news_items = NewsItem.search_for(query, govbox_enabled_feeds.select { |feed| !feed.is_video? }, 13.months.ago, 1)
      @video_news_items = NewsItem.search_for(query, govbox_enabled_feeds.select { |feed| feed.is_video? }, nil, 1)
      @med_topic = MedTopic.search_for(query, I18n.locale.to_s) if affiliate.is_medline_govbox_enabled?
      affiliate_twitter_profiles = affiliate.twitter_profiles.collect(&:twitter_id)
      @tweets = Tweet.search_for(query, affiliate_twitter_profiles, 3.months.ago) if affiliate_twitter_profiles.any? and affiliate.is_twitter_govbox_enabled?
      @photos = FlickrPhoto.search_for(query, affiliate) if affiliate.is_photo_govbox_enabled?
      if affiliate.form_agency_ids.present?
        if qualify_for_form_fulltext_search?
          @forms = Form.search_for(query, {:form_agencies => affiliate.form_agency_ids, :verified => true, :count => 1})
        else
          form_results = Form.verified.where('title = ? AND form_agency_id IN (?)', query.squish, affiliate.form_agency_ids).limit(1)[0, 1]
          @forms = Struct.new(:total, :hits, :results).new(form_results.count, nil, form_results)
        end
      end
    end
  end

  def log_serp_impressions
    modules = []
    modules << @module_tag if @module_tag
    modules << "OVER" << "BSPEL" unless self.spelling_suggestion.nil?
    modules << "SREL" unless self.related_search.nil? or self.related_search.empty?
    modules << 'NEWS' if self.news_items.present? and self.news_items.total > 0
    modules << 'VIDS' if self.video_news_items.present? and self.video_news_items.total > 0
    modules << "AIDOC" unless self.indexed_documents.nil? or self.indexed_documents.empty?
    modules << "BOOS" unless self.boosted_contents.nil? or self.boosted_contents.total.zero?
    modules << "MEDL" unless self.med_topic.nil?
    modules << "JOBS" if self.jobs.present?
    modules << "TWEET" unless self.tweets.nil? or self.tweets.total.zero?
    modules << "PHOTO" unless self.photos.nil? or self.photos.total.zero?
    vertical = get_vertical
    QueryImpression.log(vertical, affiliate.name, self.query, modules)
  end


  def odie_search_class
    OdieSearch
  end

  def get_vertical
    :web
  end

end
