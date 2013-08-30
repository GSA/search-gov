module ConnectionsHelper
  def render_connected_affiliate_links(affiliate, query)
    return if affiliate.connections.blank?

    content = []
    affiliate.connections.each_with_index do |connection, index|
      first = index == 0 ? ' first' : ''
      content << content_tag(:li,
                             link_to(connection.label,
                                     search_path(:affiliate => connection.connected_affiliate.name, :query => query),
                                     :class => "updatable#{first}").html_safe)
    end
    content_tag(:ul, content.join("\n").html_safe)
  end

  def link_to_add_new_connection(title, site)
    link_to title,
            new_connection_site_display_path(site),
            remote: true,
            data: { params: { index: site.connections.length } },
            id: 'new-connection-trigger'
  end
end
