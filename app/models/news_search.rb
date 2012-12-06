class NewsSearch < Search
  DEFAULT_PER_PAGE = 10
  DEFAULT_VIDEO_PER_PAGE = 21
  attr_reader :rss_feed,
              :hits,
              :since,
              :until,
              :facets

  def initialize(options = {})
    super(options)
    @query = (@query || '').squish
    @channel = options[:channel]

    if options[:until_date].present? || options[:since_date].present?
      if options[:until_date].present?
        @until = Time.strptime(options[:until_date], I18n.t(:cdr_format)).utc.end_of_day rescue Time.current.end_of_day
      end

      if options[:since_date].present?
        @since = Time.strptime(options[:since_date], I18n.t(:cdr_format)).utc.beginning_of_day rescue nil
        @since ||= @until ? @until.advance(years: -1).beginning_of_day : Time.current.advance(years: -1).beginning_of_day
        @since, @until = @until.beginning_of_day, @since.end_of_day if @since and @until and @since > @until
      end
    end

    if options[:tbs] and @since.nil? and @until.nil?
      @tbs = options[:tbs]
      @since = since_when(@tbs) if @tbs
    end

    assign_rss_feed(options[:channel])
    if @rss_feed
      @rss_feeds = [@rss_feed]
    else
      @rss_feeds = navigable_feeds
      @rss_feed = @rss_feeds.first if @rss_feeds.count == 1
    end
    @hits, @total = [], 0
    @contributor, @subject, @publisher = options[:contributor], options[:subject], options[:publisher]
    @sort_by_relevance = options[:sort_by] == 'r'
    assign_per_page
  end

  def search
    NewsItem.search_for(@query, @rss_feeds, {since: @since, until: @until}, @page, @per_page,
                        @contributor, @subject, @publisher, @sort_by_relevance)
  end

  def cache_key
    date_range = ''
    if @since || @until
      date_range << "#{@since.to_date.to_s}" if @since
      date_range << "..#{@until.to_date.to_s}" if @until
    end
    [@affiliate.id, @query, @channel, date_range, @page, @per_page].join(':')
  end

  protected

  def handle_response(response)
    if response
      @total = response.total
      @facets = response.facets
      @results = paginate(process_results(response))
      @hits = response.hits(:verify => true)
      @startrecord = ((@page - 1) * 10) + 1
      @endrecord = @startrecord + @results.size - 1
      @module_tag = @total > 0 ? 'NEWS' : nil
    end
  end

  def assign_rss_feed(channel_id)
    @rss_feed = @affiliate.rss_feeds.find_by_id(channel_id.to_i) if channel_id.present?
  end

  def navigable_feeds
    @affiliate.rss_feeds.navigable_only
  end

  def assign_per_page
    @per_page = @rss_feed && @rss_feed.is_video? ? DEFAULT_VIDEO_PER_PAGE : DEFAULT_PER_PAGE
  end

  def process_results(response)
    processed = response.hits(:verify => true).collect do |hit|
      {
        'title' => highlight_solr_hit_like_bing(hit, :title),
        'link' => hit.instance.link,
        'publishedAt' => hit.instance.published_at,
        'content' => highlight_solr_hit_like_bing(hit, :description)
      }
    end
    processed.compact
  end

  def since_when(tbs)
    if tbs && (extent = NewsItem::TIME_BASED_SEARCH_OPTIONS[tbs])
      1.send(extent).ago.to_time.beginning_of_day
    end
  end

  def log_serp_impressions
    modules = []
    modules << @module_tag if @module_tag
    modules << "SREL" unless @related_search.nil? or @related_search.empty?
    QueryImpression.log(:news, @affiliate.name, @query, modules)
  end

  def allow_blank_query?
    true
  end
end