# frozen_string_literal: true

module ReactHelper
  def search_results_layout(search, params, vertical, affiliate)
    data = {
      additionalResults: search.govbox_set,
      currentLocale: affiliate.locale,
      navigationLinks: navigation_links(search, params),
      noResultsMessage: no_result_message(search),
      params: params,
      relatedSites: related_sites(affiliate.connections, search.query),
      resultsData: search.normalized_results,
      translations: translations(affiliate.locale),
      vertical: vertical,
      alert: (search_page_alert(affiliate.alert) if affiliate.alert.present?)
    }

    react_component('SearchResultsLayout', data.compact_blank)
  end

  private

  def no_result_message(search)
    return unless search.results.blank? && search.query.present?

    search.affiliate.no_results_error
  end

  def translations(locale)
    I18n.backend.translations.slice(:en, locale.to_sym)
  end

  def search_page_alert(alert)
    return if alert.text.blank? && alert.title.blank?

    alert.slice('text', 'title')
  end

  def related_sites(connections, query)
    connections.map do |connection|
      {
        label: connection.label,
        link: search_url(affiliate: connection.connected_affiliate.name, query: query)
      }
    end
  end

  def navigation_links(search, search_params)
    non_default_search_navigable = detect_non_default_search_navigable(search)

    renderable_navigations(search).map do |navigation|
      navigable = navigation.navigable

      {
        active: non_default_search_navigable == navigable,
        label: navigable.name,
        link: navigable_path(navigable, search, search_params)
      }
    end
  end
end
