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
      language: @affiliate.locale,
      q: @query)

    @modules = []

    init_best_bets
    init_federal_register_documents
    init_jobs
    init_news_items
    init_video_news_items
    init_med_topic
    init_tweets
    init_related_search
  end

  private

  def init_related_search
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
      @tweets = ElasticTweet.search_for(search_options)
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
        since: 13.months.ago.beginning_of_day)
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
        since: 4.months.ago.beginning_of_day)
      @news_items = ElasticNewsItem.search_for search_options
      @modules << 'NEWS' if elastic_results_exist?(@news_items)
    end
  end

  def init_jobs
    if @affiliate.jobs_enabled?
      @jobs = Jobs.search build_jobs_search_options
      if @jobs.present?
        translate_jobs_highlights unless highlighting_disabled?
        @modules << 'JOBS'
      end
    end
  end

  def build_jobs_search_options
    jobs_options = { query: @query, size: 10 }
    jobs_options[:hl] = 1 unless highlighting_disabled?
    org_tags_hash = @affiliate.has_organization_codes? ? { organization_id: @affiliate.agency.agency_organization_codes.first.organization_code } : { tags: 'federal' }
    jobs_options.merge!(org_tags_hash)
    jobs_options.merge!(lat_lon: [@geoip_info.latitude, @geoip_info.longitude].join(',')) if @geoip_info.present?
    jobs_options
  end

  def translate_jobs_highlights
    pre_tag = (@highlighting_options[:pre_tags] || DEFAULT_JOB_HIGHLIGHTING_OPTIONS[:pre_tags]).first
    post_tag = (@highlighting_options[:post_tags] || DEFAULT_JOB_HIGHLIGHTING_OPTIONS[:post_tags]).first
    @jobs.each do |job_opening|
      job_opening.position_title = job_opening.position_title.
        gsub(/<em>/, pre_tag).
        gsub(/<\/em>/, post_tag)
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

  def init_best_bets
    search_options = build_search_options(affiliate_id: @affiliate.id)
    @boosted_contents = ElasticBoostedContent.search_for(search_options.merge(size: 3))
    @modules << 'BOOS' if elastic_results_exist?(@boosted_contents)
    @featured_collections = ElasticFeaturedCollection.search_for(search_options.merge(size: 1))
    @modules << 'BBG' if elastic_results_exist?(@featured_collections)
  end

  def build_search_options(options)
    @base_search_options.merge options
  end

  def elastic_results_exist?(elastic_results)
    elastic_results.present? && elastic_results.total > 0
  end

  def highlighting_disabled?
    @highlighting_options[:highlighting] === false
  end
end
