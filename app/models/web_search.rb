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
           :related_search,
           :to => :@govbox_set,
           :allow_nil => true

  def initialize(options = {})
    super(options)
    @options = options
    offset = (page - 1) * per_page + 1
    search_engine_option = @affiliate.present? ? @affiliate.search_engine : DEFAULT_SEARCH_ENGINE_OPTION
    formatted_query_klass = "#{search_engine_option}FormattedQuery"
    search_engine_klass = "#{search_engine_option}Search"
    query_options = options.merge(included_domains: @affiliate.domains_as_array,
                                  excluded_domains: @affiliate.excluded_domains_as_array,
                                  scope_ids: @affiliate.scope_ids_as_array,
                                  scope_keywords: @affiliate.scope_keywords_as_array)
    formatted_query = formatted_query_klass.constantize.new(query_options)
    @matching_site_limits = formatted_query.matching_site_limits
    @search_engine = search_engine_klass.constantize.new(options.merge(query: formatted_query.query, offset: offset))
  end

  #TODO: used by helpers and for logging module name
  def are_results_by_bing?
    @indexed_results.nil?
  end

  class << self
    def results_present_for?(query, affiliate)
      search = new(query: query, affiliate: affiliate)
      search.run
      spelling_ok = search.spelling_suggestion.nil? || search.spelling_suggestion.fuzzily_matches?(query)
      search.results.present? && spelling_ok
    end
  end

  def has_related_searches?
    related_search && related_search.size > 0
  end

  def has_boosted_contents?
    boosted_contents and boosted_contents.results.size > 0
  end

  def method_missing(meth, *args, &block)
    if meth.to_s =~ /^has_(.+)\?$/
      run_has_method($1)
    else
      super
    end
  end

  def run_has_method(member_name)
    send(member_name).present? and send(member_name).total > 0
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
    @results = paginate(post_process_web_results(response.results))
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

  def post_process_web_results(results)
    post_processor = WebResultsPostProcessor.new(@query, @affiliate, results)
    post_processor.post_processed_results
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
    @govbox_set = GovboxSet.new(query, affiliate, geoip_info) if first_page?
  end

  def log_serp_impressions
    modules = []
    modules << module_tag if module_tag
    modules << "OVER" << "BSPEL" unless self.spelling_suggestion.nil?
    modules << "SREL" if self.has_related_searches?
    modules << 'NEWS' if self.has_news_items?
    modules << 'VIDS' if self.has_video_news_items?
    modules << "FORM" if self.has_forms?
    modules << "BBG" if self.has_featured_collections?
    modules << "BOOS" if self.has_boosted_contents?
    modules << "MEDL" unless self.med_topic.nil?
    modules << "JOBS" if self.jobs.present?
    modules << "TWEET" if self.has_tweets?
    modules << "PHOTO" if self.has_photos?
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