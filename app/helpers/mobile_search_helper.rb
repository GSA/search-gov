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

  def extra_pagination_params(search)
    if search.is_a?(ImageSearch) && search.module_tag == 'IMAG'
      { cr: true }
    end
  end

  def eligible_for_commercial_results?(search)
    is_last_page = search.total <= search.per_page * search.page
    return unless is_last_page

    case search
      when ImageSearch
        search.affiliate.is_bing_image_search_enabled? && search.module_tag == 'FLICKR'
      when BlendedSearch
        true
      else
        false
    end
  end
end
