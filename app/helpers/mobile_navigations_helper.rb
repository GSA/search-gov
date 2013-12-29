module MobileNavigationsHelper
  def mobile_navigations(search, search_params)
    return if is_inactive_site_search?(search) || is_inactive_news_search?(search)

    navigations = renderable_navigations(search.affiliate)
    return if navigations.blank?

    dc = search.is_a?(SiteSearch) ? search.document_collection : nil
    rss_feed = search.is_a?(NewsSearch) ? search.rss_feed : nil

    html = search_everything_navigation(search, search_params)
    nav_items = build_navigations_items(search, search_params, dc, rss_feed, navigations)

    if navigations.length <= 3
      navigation_wrapper(html.html_safe << nav_items.join("\n").html_safe)
    else
      active_navigation_index = detect_active_navigation_index(search, navigations, dc, rss_feed)
      navigations_with_dropdown(html, nav_items, active_navigation_index)
    end
  end

  def is_inactive_site_search?(search)
    search.is_a?(SiteSearch) &&
        search.document_collection &&
        !search.document_collection.navigation.is_active?
  end

  def is_inactive_news_search?(search)
    search.is_a?(NewsSearch) &&
        search.rss_feed &&
        !search.rss_feed.navigation.is_active?
  end

  def renderable_navigations(affiliate)
    navigations = affiliate.navigations.active
    navigations.reject! do |n|
      n.navigable.is_a?(ImageSearchLabel) ||
          (n.navigable.is_a?(RssFeed) && n.navigable.is_managed?)
    end
    navigations.to_a
  end

  def search_everything_navigation(search, search_params)
    search_label = search.affiliate.default_search_label
    is_active = search.instance_of?(WebSearch)
    params = search_params.slice(:affiliate, :external_tracking_code_disabled, :m).
        merge(query: search.query)

    navigation_item(is_active, search_label, search_path(params))
  end

  def build_navigations_items(search, search_params, dc, rss_feed, navigations)
    navigations.map do |navigation|
      case navigation.navigable
      when DocumentCollection
        document_collection_navigation(search, search_params, dc, navigation)
      when RssFeed
        rss_feed_navigation(search, search_params, rss_feed, navigation)
      end
    end
  end

  def document_collection_navigation(search, search_params, dc, navigation)
    navigable = navigation.navigable
    is_active = dc == navigable
    dc_params = search_params.slice(:affiliate, :external_tracking_code_disabled, :m, :sitelimit).
        merge(dc: navigable.id,
              query: search.query)

    navigation_item(is_active, navigable.name, docs_search_path(dc_params))
  end

  def rss_feed_navigation(search, search_params, rss_feed, navigation)
    navigable = navigation.navigable
    is_active = rss_feed == navigable
    rss_params = search_params.slice(:affiliate, :external_tracking_code_disabled, :m, :tbs).
        merge(channel: navigable.id,
              query: search.query)

    navigation_item(is_active, navigable.name, news_search_path(rss_params))
  end

  def detect_active_navigation_index(search, navigations, dc, rss_feed)
    return if search.instance_of?(WebSearch) || (dc.nil? && rss_feed.nil?)
    navigations.map(&:navigable).find_index { |n| (n == dc) || (n == rss_feed) }
  end

  def navigations_with_dropdown(html, nav_items, active_nav_index)
    if active_nav_index and active_nav_index > 1
      active_nav_html = nav_items.slice!(active_nav_index)
      visible_nav_html = nav_items.slice!(0) << "\n" << active_nav_html << "\n"
    else
      visible_nav_html = nav_items.slice!(0, 2).join("\n")
    end
    dropdown_nav_html = nav_items

    html << "\n" << visible_nav_html.html_safe
    html << dropdown_navigation_wrapper(dropdown_nav_html.join("\n").html_safe)
    navigation_wrapper(html)
  end

  def navigation_wrapper(html)
    render partial: 'nav_wrapper', locals: { html: html }
  end

  def dropdown_navigation_wrapper(html)
    render partial: 'dropdown_nav_wrapper', locals: { html: html }
  end

  def navigation_item(is_active, title, path)
    css_class = is_active ? 'active' : nil
    content_tag(:li, nil, class: css_class) do
      link_to_unless is_active, title, path do
        content_tag(:span, title)
      end
    end
  end
end
