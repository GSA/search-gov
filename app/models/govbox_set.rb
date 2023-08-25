class GovboxSet
  DEFAULT_JOB_HIGHLIGHTING_OPTIONS = {
    pre_tags: %w[<strong>],
    post_tags: %w[</strong>]
  }.freeze

  attr_reader :boosted_contents,
              :featured_collections,
              :federal_register_documents,
              :jobs,
              :med_topic,
              :modules,
              :news_items,
              :related_search,
              :video_news_items

  def initialize(query, affiliate, geoip_info, options = {})
    @query = query
    @affiliate = affiliate
    @geoip_info = geoip_info
    @highlighting_options = options.slice(:highlighting, :pre_tags, :post_tags)
    @base_search_options = @highlighting_options.merge(
      language: @affiliate.indexing_locale,
      q: @query
    )

    @site_limits = extract_site_limits(options[:site_limits])
    @modules = []

    init_text_best_bets

    return if @site_limits.present?

    init_graphic_best_bets
    init_federal_register_documents
    init_med_topic
    init_news_items
    init_video_news_items
    init_jobs
    init_related_search
  end

  def as_json(*_args)
    {
      recommendedBy: @affiliate.display_name,
      textBestBets: format_text_best_bets,
      graphicsBestBet: format_graphics_best_bet,
      jobs: format_jobs,
      healthTopic: format_health_topic,
      federalRegisterDocuments: format_federal_register_documents,
      youtubeNewsItems: format_video_news_items,
      oldNews: format_old_news,
      newNews: format_new_news
    }.compact_blank
  end

  private

  def translate_highlights(body)
    body&.gsub(/\uE000/, '<strong>')&.gsub(/\uE001/, '</strong>')
  end

  def videos_exist?
    video_feeds = RssFeed.includes(:rss_feed_urls).owned_by_youtube_profile.where(owner_id: @affiliate.youtube_profile_ids)
    video_feeds.present? && @affiliate.is_video_govbox_enabled? && @video_news_items.total.positive?
  end

  def first_video_result
    @video_news_items&.results&.first(1)
  end

  def format_video_news_items
    return unless videos_exist?

    first_video_result&.map { |result| result.slice(:link, :title, :description, :published_at, :youtube_thumbnail_url, :duration) }&.
      each { |result| result[:published_at] = result[:published_at].to_datetime.to_fs(:long) }
  end

  def fresh_news_items?
    return false unless @news_items

    stale_threshold = Date.current - 5
    @news_items&.results&.first(3)&.any? { |news_item| news_item.published_at.to_date >= stale_threshold }
  end

  def format_new_news
    return unless fresh_news_items?

    @news_items&.results&.first(3)&.map do |news_item|
      {
        title: translate_highlights(news_item.title),
        description: news_item.description,
        link: news_item.link,
        publishedAt: news_item.published_at.to_date
      }
    end
  end

  def format_old_news
    return nil if fresh_news_items?

    @news_items&.results&.first(3)&.map do |news_item|
      {
        title: translate_highlights(news_item.title),
        description: news_item.description,
        link: news_item.link,
        publishedAt: news_item.published_at.to_date
      }
    end
  end

  def format_text_best_bets
    return if @affiliate.boosted_contents.empty? || @boosted_contents&.results.blank?

    @boosted_contents&.results&.map { |result| result.slice(:title, :url, :description) }
  end

  def format_graphics_best_bet
    return if @affiliate.featured_collections.empty?

    @featured_collections&.results&.first&.as_json&.except(:id)
  end

  def format_jobs
    return unless @affiliate.jobs_enabled?

    @jobs&.
      map { |job| job.slice(:position_title, :position_uri, :position_location_display, :organization_name, :minimum_pay, :maximum_pay, :rate_interval_code, :application_close_date) }&.
      each { |job| job[:application_close_date] = Date.parse(job[:application_close_date]).to_fs(:long) }
  end

  def format_health_topic
    return unless @med_topic

    {
      title: @med_topic.medline_title,
      description: @med_topic.truncated_summary,
      url: @med_topic.medline_url,
      relatedTopics: format_health_topic_related_topics,
      studiesAndTrials: format_health_topic_trials_and_studies
    }.compact_blank
  end

  def format_health_topic_related_topics
    @med_topic&.med_related_topics&.limit(3)&.map { |topic| topic.slice(:title, :url) }
  end

  def format_health_topic_trials_and_studies
    @med_topic&.med_sites&.limit(2)&.map { |study| study.slice(:title, :url) }
  end

  def format_federal_register_documents
    @federal_register_documents&.results&.first(3)&.map { |frd| frd.slice(:title, :document_type, :document_number, :publication_date, :comments_close_on, :start_page, :end_page, :page_length, :contributing_agency_names, :html_url) }&.
      each do |frd|
      frd[:comments_close_on] = frd[:comments_close_on].to_fs(:long)
      frd[:publication_date] = frd[:publication_date].to_fs(:long)
    end
  end

  def extract_site_limits(site_limits)
    return if site_limits.blank?

    site_limits.map do |site_limit|
      UrlParser.strip_http_protocols(site_limit)
    end
  end

  def init_related_search
    return unless @affiliate.is_related_searches_enabled?

    @related_search = SaytSuggestion.related_search(@query, @affiliate, @highlighting_options)
    @modules << 'SREL' if @related_search.present?
  end

  def init_med_topic
    return unless @affiliate.is_medline_govbox_enabled?

    @med_topic = MedTopic.search_for(@query, I18n.locale.to_s)
    @modules << 'MEDL' if @med_topic
  end

  def init_video_news_items
    return unless @affiliate.is_video_govbox_enabled?

    youtube_profile_ids = @affiliate.youtube_profile_ids
    video_feeds = RssFeed.includes(:rss_feed_urls).owned_by_youtube_profile.where(owner_id: youtube_profile_ids)
    return unless video_feeds.present?

    search_options = build_search_options(
      excluded_urls: @affiliate.excluded_urls,
      rss_feeds: video_feeds,
      since: 13.months.ago.beginning_of_day,
      title_only: true
    )
    @video_news_items = ElasticNewsItem.search_for(search_options)
    @modules << 'VIDS' if elastic_results_exist?(@video_news_items)
  end

  def init_news_items
    return unless @affiliate.is_rss_govbox_enabled?

    non_managed_feeds = @affiliate.rss_feeds.non_mrss.non_managed.includes(:rss_feed_urls).to_a
    return unless non_managed_feeds.present?

    search_options = build_search_options(
      excluded_urls: @affiliate.excluded_urls,
      rss_feeds: non_managed_feeds,
      since: 4.months.ago.beginning_of_day,
      title_only: true
    )
    @news_items = ElasticNewsItem.search_for(search_options)
    @modules << 'NEWS' if elastic_results_exist?(@news_items)
  end

  def init_jobs
    return unless @affiliate.jobs_enabled?

    job_results = Jobs.search({
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

  def init_federal_register_documents
    if @affiliate.is_federal_register_document_govbox_enabled? &&
       @affiliate.agency && @affiliate.agency.federal_register_agency.present?

      search_options = build_search_options(
        federal_register_agency_ids: [@affiliate.agency.federal_register_agency_id],
        language: 'en'
      )
      @federal_register_documents = ElasticFederalRegisterDocument.search_for(search_options)
      @modules << 'FRDOC' if elastic_results_exist?(@federal_register_documents)
    end
  end

  def init_text_best_bets
    return if @affiliate.boosted_contents.empty?

    search_options = build_search_options(affiliate_id: @affiliate.id, size: 2, site_limits: @site_limits)
    @boosted_contents = ElasticBoostedContent.search_for(search_options)
    @modules << 'BOOS' if elastic_results_exist?(@boosted_contents)
  end

  def init_graphic_best_bets
    return if @affiliate.featured_collections.empty?

    search_options = build_search_options(affiliate_id: @affiliate.id, size: 1)
    @featured_collections = ElasticFeaturedCollection.search_for(search_options)
    return unless elastic_results_exist?(@featured_collections)

    if elastic_results_exist?(@boosted_contents) and @boosted_contents.total > 1
      search_options = build_search_options(affiliate_id: @affiliate.id, size: 1, site_limits: @site_limits)
      @boosted_contents = ElasticBoostedContent.search_for(search_options)
    end
    @modules << 'BBG'
  end

  def build_search_options(options)
    @base_search_options.merge(options)
  end

  def elastic_results_exist?(elastic_results)
    elastic_results.present? && elastic_results.total > 0
  end
end
