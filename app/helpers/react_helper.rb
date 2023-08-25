# frozen_string_literal: true

module ReactHelper
  def search_results_layout(search, params, vertical, affiliate)
    data = {
      additionalResults: search.govbox_set,
      locale: YAML.load_file("config/locales/#{affiliate.locale}.yml"),
      noResultsMessage: (search.affiliate.no_results_error if search.results.blank? && search.query.present?),
      params: params,
      relatedSites: related_sites(affiliate.connections, search.query),
      resultsData: search.normalized_results,
      vertical: vertical
    }

    react_component('SearchResultsLayout', data)
  end

  private

  def related_sites(connections, query)
    connections.map do |connection|
      {
        label: connection.label,
        link: search_url(affiliate: connection.connected_affiliate.name, query: query)
      }
    end
  end
end
