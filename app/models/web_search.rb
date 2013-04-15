class WebSearch < Search
  DEFAULT_SEARCH_ENGINE_OPTION = 'Bing'

  attr_reader :matching_site_limits

  delegate :boosted_contents,
           :agency,
           :med_topic,
           :news_items,
           :video_news_items,
           :featured_collections,
           :tweets,
           :photos,
           :forms,
           :jobs,
           :has_boosted_contents?,
           :has_featured_collections?,
           :has_forms?,
           :to => :@govbox_set,
           :allow_nil => true

  def initialize(options = {})
    super(options)
    offset = (page - 1) * per_page + 1
    search_engine_option = @affiliate.present? ? @affiliate.search_engine : DEFAULT_SEARCH_ENGINE_OPTION
    formatted_query_klass = "#{search_engine_option}FormattedQuery"
    search_engine_klass = "#{search_engine_option}Search"
    formatted_query = formatted_query_klass.constantize.new(options)
    @matching_site_limits = formatted_query.matching_site_limits
    @search_engine = search_engine_klass.constantize.new(options.merge(query: formatted_query.query, offset: offset))
  end

  #TODO: used by helpers and for logging module name
  def are_results_by_bing?
    #self.indexed_results.nil?
    true
  end

  class << self
    def results_present_for?(query, affiliate)
      search = new(query: query, affiliate: affiliate)
      search.run
      spelling_ok = search.spelling_suggestion.nil? || search.spelling_suggestion.fuzzily_matches?(query)
      search.results.present? && spelling_ok
    end
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
      #TODO: fix module name: BWEB and GWEB?
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
          #TODO: ditch cache_url and deeplinks
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
    @govbox_set = GovboxSet.new(query, affiliate, geoip_info) if first_page?
  end

  def log_serp_impressions
    modules = []
    modules << @module_tag if @module_tag
    modules << "OVER" << "BSPEL" unless self.spelling_suggestion.nil?
    modules << "SREL" unless self.related_search.nil? or self.related_search.empty?
    modules << 'NEWS' if self.news_items.present? and self.news_items.total > 0
    modules << 'VIDS' if self.video_news_items.present? and self.video_news_items.total > 0
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