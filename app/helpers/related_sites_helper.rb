module RelatedSitesHelper
  def related_site_item(connection, query)
    content_tag :li,
                related_site_link(connection, query),
                class: 'related-site'
  end

  def related_site_link(connection, query)
    link_to connection.label,
            search_path(affiliate: connection.connected_affiliate.name, query: query)
  end
end
