class ApiVideoSearch < Search
  include DefaultModuleTaggable
  include Api::V2::SearchAsJson

  self.default_module_tag = 'VIDS'.freeze

  attr_reader :next_offset, :video_rss_feeds

  def initialize(options)
    @affiliate = options[:affiliate]

    @limit = options[:limit]
    @offset = options[:offset]
    @next_offset_within_limit = options[:next_offset_within_limit]

    @query = options[:query]
    @highlight_options = build_highlighting_options options
    @sort_by_relevance = options[:sort_by] != 'date'
    @video_rss_feeds = RssFeed.youtube_profile_rss_feeds_by_site @affiliate

    @modules = []
    @results = []
  end

  def search
    return unless @video_rss_feeds.present?

    search_options = {
      language: @affiliate.indexing_locale,
      offset: @offset,
      q: @query,
      rss_feeds: @video_rss_feeds,
      size: @limit,
      sort_by_relevance: @sort_by_relevance,
    }.reverse_merge(@highlight_options)

    ElasticNewsItem.search_for(**search_options)
  end

  def as_json(_options = {})
    video_hash = {
      total: @total,
      next_offset: @next_offset,
      results: as_json_video_news(@results)
    }
    { video: video_hash }
  end

  protected

  def build_highlighting_options(options)
    { highlighting: options[:enable_highlighting] }.
      merge(Api::V2::HighlightOptions::DEFAULT)
  end

  def handle_response(response)
    return unless response

    @total = response.total
    @results = response.results
    @next_offset = @offset + @limit if @next_offset_within_limit && more_results_available?
  end

  def more_results_available?
    @total > (@offset + @limit)
  end

  def log_serp_impressions
    @modules << default_module_tag if @results.present?
  end
end
