module MobileNavigationsHelper
  def navigation_heading
    @affiliate.left_nav_label.present? ? @affiliate.left_nav_label : I18n.t(:search)
  end

  def navigations_and_logo(search, search_params, navigations)
    if is_inactive_site_search?(search)
      return navigation_context(search.document_collection)
    elsif is_inactive_news_search?(search)
      return navigation_context(search.rss_feed)
    end

    if navigations.present?
      mobile_navigations(search, search_params, navigations).html_safe
    end
  end

  def mobile_navigations(search, search_params, navigations)
    dc = search.is_a?(SiteSearch) ? search.document_collection : nil
    rss_feed = search.is_a?(NewsSearch) ? search.rss_feed : nil

    html = search_everything_navigation(search, search_params)
    nav_items = build_navigations_items(search, search_params, dc, rss_feed, navigations)
    active_navigation_index = detect_active_navigation_index(search, navigations, dc, rss_feed)
    build_navigations html, nav_items, navigations.length, active_navigation_index
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

  def navigation_context(navigable)
    nav_html = navigation_item(true, navigable.name)
    navigation_wrapper(nav_html, 'in')
  end

  def renderable_navigations(affiliate)
    navigations = affiliate.navigations.active
    navigations.reject! do |n|
      navigable = n.navigable
      navigable.is_a?(ImageSearchLabel) ||
          (navigable.is_a?(RssFeed) &&
              (navigable.is_managed? || navigable.show_only_media_content?))
    end
    navigations.to_a
  end

  def search_everything_navigation(search, search_params)
    search_label = search.affiliate.default_search_label
    is_active = search.instance_of?(WebSearch)
    params = search_params.slice(:affiliate, :m).
        merge(query: search.query)

    navigation_item(is_active, search_label, search_path(params))
  end

  def build_navigations_items(search, search_params, dc, rss_feed, navigations)
    query = search.query
    navigations.map do |navigation|
      navigable = navigation.navigable
      active_navigable, path =
          case navigable
          when DocumentCollection
            [dc, document_collection_search_path(search_params, navigable, query)]
          when RssFeed
            [rss_feed, rss_feed_search_path(search_params, navigable, query)]
          end
      build_navigation(active_navigable, navigable, path)
    end
  end

  def document_collection_search_path(search_params, navigable, query)
    dc_params = navigable_params(search_params, :dc, navigable.id, query,
                                 :affiliate, :m, :sitelimit)
    docs_search_path(dc_params)
  end

  def rss_feed_search_path(search_params, navigable, query)
    rss_params = navigable_params(search_params, :channel, navigable.id, query,
                                  :affiliate, :m, :tbs)
    news_search_path(rss_params)
  end

  def navigable_params(search_params, id_sym, id, query, *keys)
    search_params.slice(*keys).merge(id_sym => id, :query => query)
  end

  def build_navigation(active_navigable, navigable, path)
    is_active = active_navigable == navigable
    navigation_item(is_active, navigable.name, path)
  end

  def navigation_item(is_active, title, path = nil)
    css_class = is_active ? 'active' : nil
    content_tag(:li, nil, class: css_class) do
      link_to_unless is_active, title, path do
        content_tag(:span, title)
      end
    end
  end

  def detect_active_navigation_index(search, navigations, dc, rss_feed)
    return if search.instance_of?(WebSearch) || (dc.nil? && rss_feed.nil?)
    navigations.map(&:navigable).find_index { |n| (n == dc) || (n == rss_feed) }
  end

  def build_navigations(html, nav_items, navigations_length, active_nav_index)
    if navigations_length <= 3
      navigation_wrapper(html.html_safe << nav_items.join("\n").html_safe)
    else
      navigations_with_dropdown(html, nav_items, active_nav_index)
    end
  end

  def navigation_wrapper(html, nav_class = nil)
    render partial: '/searches/nav_wrapper', locals: { html: html, nav_class: nav_class }
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

  def dropdown_navigation_wrapper(html)
    render partial: '/searches/dropdown_nav_wrapper', locals: { html: html }
  end
end
