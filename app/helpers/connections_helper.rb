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
end