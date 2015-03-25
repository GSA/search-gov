module MobileMenuHelper
  def has_menu_items?(search, navigations)
    if is_inactive_site_search?(search) || is_inactive_news_search?(search)
      search.affiliate.connections.present? || search.affiliate.managed_header_links.present?
    else
      navigations.present? || search.affiliate.connections.present? || search.affiliate.managed_header_links.present?
    end
  end

  def menu_button_class(site)
    'has-browse-site' if site.managed_header_links.present?
  end

  def main_menu(search, search_params, navigations)
    content_tag :div, id: 'main-menu', class: 'menu collapse' do
      content = content_tag :h2, I18n.t(:'searches.menu'), class: 'content-heading'
      content << menu_list(search, search_params, navigations)
      content.html_safe
    end
  end

  def menu_list(search, search_params, navigations)
    html = search_menu_list_html search, search_params, navigations

    related_sites_html = related_site_menu_list_html search
    append_list_items html, related_sites_html

    header_links_html = header_link_menu_list_html search.affiliate.managed_header_links
    append_list_items html, header_links_html

    content_tag :ul, html.html_safe
  end

  def search_menu_list_html(search, search_params, navigations)
    non_default_search_navigable = detect_non_default_search_navigable search

    html = build_standalone_search_menu_item non_default_search_navigable if navigations.blank?
    return '' if html.blank? and navigations.blank?

    html ||= default_search_menu_item search, search_params
    nav_items = build_search_menu_items search, search_params, non_default_search_navigable, navigations
    html << nav_items.join("\n").html_safe

    dropdown_menu_wrapper html, 'search-menu-dropdown', navigation_heading
  end

  def build_standalone_search_menu_item(non_default_search_navigable)
    return unless non_default_search_navigable
    menu_item non_default_search_navigable.name, true if non_default_search_navigable
  end

  def default_search_menu_item(search, search_params)
    search_everything_builder search, search_params do |label, is_active, path|
      menu_item label, is_active, path
    end
  end

  def build_search_menu_items(search, search_params, non_default_search_navigable, navigations)
    navigation_builder search, search_params, non_default_search_navigable, navigations do |navigable_name, is_active, path|
      menu_item navigable_name, is_active, path
    end
  end

  def menu_item(title, is_active, path = nil)
    content_tag :li do
      link_to_unless is_active, title, path do
        content_tag :span, title
      end
    end
  end

  def related_site_menu_list_html(search)
    connections = search.affiliate.connections.includes(:connected_affiliate)
    return if connections.blank?

    items = connections.map { |conn| related_site_item(conn, search.query) }
    dropdown_menu_wrapper items.join("\n"),
                          'related-sites-menu-dropdown',
                          related_sites_dropdown_label(search.affiliate.related_sites_dropdown_label)
  end

  def header_link_menu_list_html(header_links)
    return if header_links.blank?

    items = header_links.map do |link|
      content_tag :li, link_to(link[:title], link[:url])
    end

    dropdown_menu_wrapper items.join("\n"),
                          'header-links-menu-dropdown',
                          I18n.t(:'searches.browse_site')
  end

  def dropdown_menu_wrapper(html, id, show_more_label = I18n.t(:show_more))
    dropdown_wrapper 'searches/dropdown_menu', html, id, show_more_label
  end

  def append_list_items(html, list_items_html)
    return html if list_items_html.blank?
    html << content_tag(:li, nil, class: 'divider') if html.present? && list_items_html.present?
    html << list_items_html.html_safe
  end
end
