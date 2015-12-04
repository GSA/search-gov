class RoutedQueryImpressionLogger
  QueryRoutedSearch = Struct.new(:modules, :diagnostics)

  def self.log(affiliate, query, routed_query, request)
    mock_search = QueryRoutedSearch.new(%w(QRTD), {})
    normalized_query = query.downcase
    relevant_params = { affiliate: affiliate.name, query: normalized_query }
    SearchImpression.log(mock_search, :web, relevant_params, request)
    KeenLogger.log(:impressions, { affiliate_id: affiliate.id,
                                   module: 'QRTD',
                                   query: normalized_query,
                                   model_id: routed_query.id })
  end
end
