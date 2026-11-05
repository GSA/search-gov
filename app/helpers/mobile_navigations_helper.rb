# frozen_string_literal: true

module MobileNavigationsHelper
  def renderable_navigations(search)
    is_inactive_search?(search) ? [] : filter_navigations(search.affiliate.navigations.active)
  end

  def detect_non_default_search_navigable(search)
    return search.affiliate.image_search_label if search.is_a?(ImageSearch)
    return search.document_collection if search.try(:document_collection)

    nil
  end

  def is_default_search?(search)
    search.try(:document_collection).blank? &&
      [BlendedSearch, OpenSearch::Engine, LegacyOpenSearch::Engine].any? { |c| search.instance_of?(c) }
  end

  def navigable_path(navigable, search, search_params)
    case navigable
      when DocumentCollection
        path_for_document_collection_search(search_params, navigable, search.query)
    end
  end
end
