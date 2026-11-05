module MobileSearchHelper
  def is_inactive_search?(search)
    is_inactive_site_search?(search)
  end

  def is_inactive_site_search?(search)
    collection = search.try(:document_collection)
    collection&.navigation&.is_inactive?
  end

  def extra_pagination_params(_search)
    nil
  end

  def eligible_for_commercial_results?(_search)
    false
  end

  def render_result_pages_links?(search)
    search.is_a?(FilterableSearch)
  end
end
