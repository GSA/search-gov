class NewsSearch < FilterableSearch
  DEFAULT_VIDEO_PER_PAGE = 20

  self.default_sort_by = 'date'.freeze

  attr_reader :rss_feed,
              :aggregations

  def initialize(options = {})
    super(options)
    @query = (@query || '').squish
    if options[:channel].present?
      @channel = begin
        options[:channel].to_i
      rescue
        nil
      end
    end
    @enable_highlighting = options[:enable_highlighting]

    if @channel
      assign_rss_feed
      @rss_feeds = @rss_feed ? [@rss_feed] : []
    else
      @rss_feeds = navigable_feeds
      @rss_feed = @rss_feeds.first if @rss_feeds.count == 1
    end

    if @rss_feeds.any?(&:is_managed?) and @affiliate.youtube_profile_ids.present?
      youtube_feeds = RssFeed.youtube_profile_rss_feeds_by_site(@affiliate)
      @rss_feeds = @rss_feeds.reject(&:is_managed?)
      @rss_feeds.push(*youtube_feeds)
    end

    @tags = @rss_feed && @rss_feed.show_only_media_content? ? %w[image] : []

    @total = 0
    @contributor = options[:contributor]
    @subject = options[:subject]
    @publisher = options[:publisher]
    return unless @rss_feed and @rss_feed.is_managed? || @rss_feed.show_only_media_content? and options[:per_page].blank?

    @per_page = DEFAULT_VIDEO_PER_PAGE
  end

  def sort_by_relevance?
    'r' == sort_by
  end

  def search
    return unless @rss_feeds.present?

    ElasticNewsItem.search_for(q: @query, rss_feeds: @rss_feeds, excluded_urls: @affiliate.excluded_urls,
                               since: @since, until: @until,
                               size: @per_page, offset: (@page - 1) * @per_page,
                               contributor: @contributor, subject: @subject, publisher: @publisher,
                               sort: @sort,
                               tags: @tags, language: @affiliate.indexing_locale)
  end

  def cache_key
    date_range = ''
    if @since || @until
      date_range << "#{@since.to_date}" if @since
      date_range << "..#{@until.to_date}" if @until
    end
    [@affiliate.id, @query, @channel, date_range, @page, @per_page].join(':')
  end

  def results_to_hash
    @results.map { |r| r.serializable_hash }
  end

  protected

  def handle_response(response)
    return unless response

    @total = response.total
    @aggregations = response.aggregations
    post_processor = ResultsWithBodyAndDescriptionPostProcessor.new(response.results)
    post_processor.post_process_results
    @normalized_results = post_processor.normalized_results(@total)
    @results = paginate(response.results)
    @startrecord = ((@page - 1) * @per_page) + 1
    @endrecord = @startrecord + @results.size - 1
    assign_module_tag
  end

  def assign_module_tag
    @module_tag = @total > 0 ? 'NEWS' : nil
  end

  def assign_rss_feed
    @rss_feed = @affiliate.rss_feeds.find_by_id(@channel)
  end

  def navigable_feeds
    @affiliate.rss_feeds.includes(:rss_feed_urls).navigable_only
  end

  def log_serp_impressions
    @modules << @module_tag if @module_tag
  end

  def allow_blank_query?
    true
  end
end
