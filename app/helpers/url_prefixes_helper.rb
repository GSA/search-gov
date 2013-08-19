module UrlPrefixesHelper
  def link_to_add_new_url_prefix(title, site, collection)
    link_to title,
            new_url_prefix_site_collections_path(site),
            remote: true,
            data: { params: { index: collection.url_prefixes.length } },
            id: 'new-url-prefix-trigger'
  end
end
