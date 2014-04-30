module MobileSearchHelper
  def is_inactive_search?(search)
    is_inactive_site_search?(search) || is_inactive_news_search?(search)
  end

  def is_inactive_site_search?(search)
    search.is_a?(SiteSearch) &&
        search.document_collection &&
        search.document_collection.navigation.is_inactive?
  end

  def is_inactive_news_search?(search)
    search.is_a?(NewsSearch) &&
        search.rss_feed &&
        search.rss_feed.navigation.is_inactive?
  end
end
