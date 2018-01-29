class RoutedQueryImpressionLogger
  QueryRoutedSearch = Struct.new(:modules, :diagnostics)

  def self.log(affiliate, query, request)
    mock_search = QueryRoutedSearch.new(%w(QRTD), {})
    normalized_query = query.downcase
    relevant_params = { affiliate: affiliate.name, query: normalized_query }
    SearchImpression.log(mock_search, :web, relevant_params, request)
  end
end
