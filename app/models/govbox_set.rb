class GovboxSet
  attr_reader :boosted_contents,
              :agency,
              :med_topic,
              :news_items,
              :video_news_items,
              :featured_collections,
              :tweets,
              :photos,
              :jobs,
              :related_search

  def initialize(query, affiliate, geoip_info)
    @boosted_contents = BoostedContent.search_for(query, affiliate)
    @featured_collections = FeaturedCollection.search_for(query, affiliate)
    if affiliate.is_agency_govbox_enabled?
      agency_query = AgencyQuery.find_by_phrase(query)
      @agency = agency_query.agency if agency_query
    end
    if affiliate.jobs_enabled?
      jobs_options = {query: query, size: 3, hl: 1}
      org_tags_hash = affiliate.has_organization_code? ? {organization_id: affiliate.agency.organization_code} : {tags: 'federal'}
      jobs_options.merge!(org_tags_hash)
      jobs_options.merge!(lat_lon: [geoip_info.latitude, geoip_info.longitude].join(',')) if geoip_info.present?
      @jobs = Jobs.search(jobs_options)
    end
    govbox_enabled_feeds = affiliate.rss_feeds.includes(:rss_feed_urls).govbox_enabled.to_a
    @news_items = NewsItem.search_for(query, govbox_enabled_feeds.select { |feed| !feed.is_managed? }, affiliate, since: 13.months.ago)

    youtube_profile_ids = affiliate.youtube_profile_ids
    video_feeds = govbox_enabled_feeds.any?(&:is_managed?) ? RssFeed.includes(:rss_feed_urls).owned_by_youtube_profile.where(owner_id: youtube_profile_ids) : []
    @video_news_items = NewsItem.search_for(query, video_feeds, affiliate)

    @med_topic = MedTopic.search_for(query, I18n.locale.to_s) if affiliate.is_medline_govbox_enabled?
    affiliate_twitter_ids = affiliate.searchable_twitter_ids
    @tweets = Tweet.search_for(query, affiliate_twitter_ids, 3.months.ago) if affiliate_twitter_ids.any? and affiliate.is_twitter_govbox_enabled?
    @photos = FlickrPhoto.search_for(query, affiliate) if affiliate.is_photo_govbox_enabled?
    @related_search = SaytSuggestion.related_search(query, affiliate)
  end
end
