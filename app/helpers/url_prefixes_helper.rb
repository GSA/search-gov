module UrlPrefixesHelper
  def link_to_add_new_url_prefix(title, site, collection)
    instrumented_link_to title, new_url_prefix_site_collections_path(site), collection.url_prefixes.length, 'url-prefix'
  end
end
