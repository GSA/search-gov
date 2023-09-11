# frozen_string_literal: true

module ReactHelper
  def search_results_layout(search, params, vertical, affiliate)
    data = {
      additionalResults: search.govbox_set,
      currentLocale: affiliate.locale,
      noResultsMessage: (search.affiliate.no_results_error if search.results.blank? && search.query.present?),
      params: params,
      relatedSites: related_sites(affiliate.connections, search.query),
      resultsData: search.normalized_results,
      translations: translations(affiliate.locale),
      vertical: vertical
    }

    react_component('SearchResultsLayout', data.compact_blank)
  end

  private

  def translations(locale)
    I18n.backend.translations.slice(:en, locale.to_sym)
  end

  def related_sites(connections, query)
    connections.map do |connection|
      {
        label: connection.label,
        link: search_url(affiliate: connection.connected_affiliate.name, query: query)
      }
    end
  end
end
