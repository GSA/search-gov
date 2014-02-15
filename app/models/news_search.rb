class NewsSearch < Search
  DEFAULT_VIDEO_PER_PAGE = 20.freeze
  attr_reader :rss_feed,
              :tbs,
              :since,
              :until,
              :facets

  def initialize(options = {})
    super(options)
    @query = (@query || '').squish
    @channel = options[:channel]
    @enable_highlighting = options[:enable_highlighting]

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

    if NewsItem::TIME_BASED_SEARCH_OPTIONS.keys.include?(options[:tbs]) and @since.nil? and @until.nil?
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

    if @rss_feeds.any?(&:is_managed?) and @affiliate.youtube_profile_ids.present?
      youtube_profile_ids = affiliate.youtube_profile_ids
      youtube_feeds = RssFeed.includes(:rss_feed_urls).owned_by_youtube_profile.where(owner_id: youtube_profile_ids)
      @rss_feeds.reject!(&:is_managed?)
      @rss_feeds.push *youtube_feeds
    end

    @tags = @rss_feed && @rss_feed.show_only_media_content? ? %w(image) : []

    @total = 0
    @contributor, @subject, @publisher = options[:contributor], options[:subject], options[:publisher]
    @sort_by_relevance = options[:sort_by] == 'r'
    if @rss_feed and @rss_feed.is_managed? || @rss_feed.show_only_media_content? and options[:per_page].blank?
      @per_page = DEFAULT_VIDEO_PER_PAGE
    end
  end

  def search
    ElasticNewsItem.search_for(q: @query, rss_feeds: @rss_feeds, excluded_urls: @affiliate.excluded_urls,
                               since: @since, until: @until,
                               size: @per_page, offset: (@page - 1) * @per_page,
                               contributor: @contributor, subject: @subject, publisher: @publisher,
                               sort_by_relevance: @sort_by_relevance,
                               tags: @tags, language: @affiliate.locale)
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
      @results = paginate(response.results)
      @startrecord = ((@page - 1) * @per_page) + 1
      @endrecord = @startrecord + @results.size - 1
      assign_module_tag
    end
  end

  def assign_module_tag
    @module_tag = @total > 0 ? 'NEWS' : nil
  end

  def assign_rss_feed(channel_id)
    @rss_feed = @affiliate.rss_feeds.find_by_id(channel_id.to_i) rescue nil if channel_id.present?
  end

  def navigable_feeds
    @affiliate.rss_feeds.includes(:rss_feed_urls).navigable_only
  end

  def since_when(tbs)
    if tbs && (extent = NewsItem::TIME_BASED_SEARCH_OPTIONS[tbs])
      time = 1.send(extent).ago
      time = time.beginning_of_day if extent != :hour
      time
    end
  end

  def log_serp_impressions
    modules = []
    modules << @module_tag if @module_tag
    QueryImpression.log(:news, @affiliate.name, @query, modules)
  end

  def allow_blank_query?
    true
  end
end
