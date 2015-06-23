module RoutedQueryKeywordsHelper
  def link_to_add_new_routed_query_keyword(title, site, routed_query)
    instrumented_link_to title, new_routed_query_keyword_site_routed_queries_path(site), routed_query.routed_query_keywords.length, 'routed-query-keyword'
  end
end
