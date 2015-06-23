module RoutedQueriesHelper
  def list_item_with_button_to_remove_routed_query(site, routed_query)
    path = site_routed_query_path site, routed_query.id
    message = "Are you sure you wish to remove routing to #{routed_query.url} from this site?"
    list_item_with_button_to_remove(path, message)
  end
end
