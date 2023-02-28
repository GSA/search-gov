class GovboxSet
  DEFAULT_JOB_HIGHLIGHTING_OPTIONS = {
    pre_tags: %w(<strong>),
    post_tags: %w(</strong>)
  }.freeze

  attr_reader :boosted_contents,
              :featured_collections,
              :federal_register_documents,
              :jobs,
              :med_topic,
              :modules,
              :news_items,
              :related_search,
              :tweets,
              :video_news_items

  def initialize(query, affiliate, geoip_info, options = {})
    @query, @affiliate, @geoip_info = query, affiliate, geoip_info
    @highlighting_options = options.slice(:highlighting, :pre_tags, :post_tags)
    @base_search_options = @highlighting_options.merge(
      language: @affiliate.indexing_locale,
      q: @query)

    @site_limits = extract_site_limits options[:site_limits]
    @modules = []

    init_text_best_bets

    if @site_limits.blank?
      init_graphic_best_bets
      init_federal_register_documents
      init_med_topic
      init_news_items
      init_video_news_items
      init_jobs
      init_tweets
      init_related_search
    end
  end

  private

  def extract_site_limits(site_limits)
    site_limits.map do |site_limit|
      UrlParser.strip_http_protocols site_limit
    end if site_limits.present?
  end

  def init_related_search
    return unless @affiliate.is_related_searches_enabled?

    @related_search = SaytSuggestion.related_search(@query, @affiliate, @highlighting_options)
    @modules << 'SREL' if @related_search.present?
  end

  def init_tweets
    affiliate_twitter_ids = @affiliate.searchable_twitter_ids
    search_options = build_search_options(
      since: 3.days.ago.beginning_of_day,
      size: 1,
      twitter_profile_ids: affiliate_twitter_ids)
    if affiliate_twitter_ids.any?
      @tweets = ElasticTweet.search_for(**search_options)
      @modules << 'TWEET' if elastic_results_exist?(@tweets)
    end
  end

  def init_med_topic
    if @affiliate.is_medline_govbox_enabled?
      @med_topic = MedTopic.search_for(@query, I18n.locale.to_s)
      @modules << 'MEDL' if @med_topic
    end
  end

  def init_video_news_items
    if @affiliate.is_video_govbox_enabled?
      youtube_profile_ids = @affiliate.youtube_profile_ids
      video_feeds = RssFeed.includes(:rss_feed_urls).owned_by_youtube_profile.where(owner_id: youtube_profile_ids)
      return unless video_feeds.present?

      search_options = build_search_options(
        excluded_urls: @affiliate.excluded_urls,
        rss_feeds: video_feeds,
        since: 13.months.ago.beginning_of_day,
        title_only: true)
      @video_news_items = ElasticNewsItem.search_for search_options
      @modules << 'VIDS' if elastic_results_exist?(@video_news_items)
    end
  end

  def init_news_items
    if @affiliate.is_rss_govbox_enabled?
      non_managed_feeds = @affiliate.rss_feeds.non_mrss.non_managed.includes(:rss_feed_urls).to_a
      return unless non_managed_feeds.present?

      search_options = build_search_options(
        excluded_urls: @affiliate.excluded_urls,
        rss_feeds: non_managed_feeds,
        since: 4.months.ago.beginning_of_day,
        title_only: true)
      @news_items = ElasticNewsItem.search_for(**search_options)
      @modules << 'NEWS' if elastic_results_exist?(@news_items)
    end
  end

  def init_jobs
    if @affiliate.jobs_enabled?
      job_results = Jobs.search(**{
        query: @query,
        organization_codes: @affiliate.agency&.joined_organization_codes,
        location_name: @geoip_info&.location_name,
        results_per_page: 10
      })&.search_result&.search_result_items

      if job_results.present?
        @jobs = JobResultsPostProcessor.new(results: job_results)&.post_processed_results
      end
      @modules << 'JOBS' if Jobs.query_eligible?(@query)
    end
  end

  def init_federal_register_documents
    if @affiliate.is_federal_register_document_govbox_enabled? &&
      @affiliate.agency && @affiliate.agency.federal_register_agency.present?

      search_options = build_search_options(
        federal_register_agency_ids: [@affiliate.agency.federal_register_agency_id],
        language: 'en')
      @federal_register_documents = ElasticFederalRegisterDocument.search_for search_options
      @modules << 'FRDOC' if elastic_results_exist?(@federal_register_documents)
    end
  end

  def init_text_best_bets
    return if @affiliate.boosted_contents.empty?

    search_options = build_search_options(affiliate_id: @affiliate.id, size: 2, site_limits: @site_limits)
    @boosted_contents = ElasticBoostedContent.search_for(**search_options)
    @modules << 'BOOS' if elastic_results_exist?(@boosted_contents)
  end

  def init_graphic_best_bets
    return if @affiliate.featured_collections.empty?

    search_options = build_search_options(affiliate_id: @affiliate.id, size: 1)
    @featured_collections = ElasticFeaturedCollection.search_for(**search_options)
    if elastic_results_exist?(@featured_collections)
      if elastic_results_exist?(@boosted_contents) and @boosted_contents.total > 1
        search_options = build_search_options(affiliate_id: @affiliate.id, size: 1, site_limits: @site_limits)
        @boosted_contents = ElasticBoostedContent.search_for(search_options)
      end
      @modules << 'BBG'
    end
  end

  def build_search_options(options)
    @base_search_options.merge options
  end

  def elastic_results_exist?(elastic_results)
    elastic_results.present? && elastic_results.total > 0
  end

end
