class NewsSearch
  attr_reader :query,
              :error_message,
              :affiliate,
              :rss_feed,
              :related_search,
              :related_search_class,
              :results,
              :hits,
              :page,
              :since,
              :total,
              :queried_at_seconds,
              :spelling_suggestion

  def initialize(affiliate, options)
    options ||= {}
    @query = (options["query"] || '').squish
    @query.downcase! if @query.ends_with? " OR"
    @affiliate = affiliate
    @since = since_when(options["tbs"])
    @page = (options["page"] || "1").to_i
    @rss_feed = @affiliate.rss_feeds.find_by_id_and_is_active(options["channel"].to_i, true) if options["channel"].present?
    @results, @related_search, @hits, @total = [], [], [], 0
    @queried_at_seconds = Time.now.to_i
  end

  def run
    @error_message = (I18n.translate :too_long) and return false if @query.length > Search::MAX_QUERYTERM_LENGTH
    @error_message = (I18n.translate :empty_query) and return false if @query.blank?
    rss_feeds = @rss_feed ? [@rss_feed] : @affiliate.active_rss_feeds
    excluded_urls = @affiliate.nil? ? [] : @affiliate.excluded_urls.collect{|url| url.url}
    news_search = NewsItem.search_for(@query, rss_feeds, @since, @page, excluded_urls)
    if news_search
      @results = news_search.results
      @hits = news_search.hits
      @total = news_search.total
      @related_search = CalaisRelatedSearch.related_search(@query, @affiliate)
      @related_search_class = CalaisRelatedSearch.name
    end
    log_serp_impressions
    true
  end

  def has_related_searches?
    @related_search && @related_search.size > 0
  end

  private

  def since_when(tbs)
    if tbs && (extent = NewsItem::TIME_BASED_SEARCH_OPTIONS[tbs])
      1.send(extent).ago
    end
  end

  def log_serp_impressions
    modules = []
    modules << "NEWS" unless @total.zero?
    modules << "CREL" unless @related_search.nil? or @related_search.empty?
    QueryImpression.log(:news, @affiliate.name, @query, modules)
  end
end