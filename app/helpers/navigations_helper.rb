module NavigationsHelper
  def detect_navigations(site, navigations)
    site.force_mobile_format? ? filter_navigations(site, navigations) : navigations
  end

  def filter_navigations(site, navigations)
    items = navigations.to_a
    items.reject! do |n|
      n.navigable.is_a?(RssFeed) && n.navigable.show_only_media_content?
    end
    unless site.has_social_image_feeds? || site.is_bing_image_search_enabled?
      items.reject! { |n| n.navigable.is_a?(ImageSearchLabel) }
    end
    items
  end

  def link_to_navigable_facet_type(nav)
    case nav.navigable_facet_type
    when 'DocumentCollection'
      link_to('Collection', edit_site_collection_path(nav.navigable.affiliate, nav.navigable))
    when 'YouTube'
      link_to('YouTube', site_youtube_channels_path(nav.navigable.owner))
    when 'RSS'
      link_to('RSS', edit_site_rss_feed_path(nav.navigable.owner, nav.navigable))
    when 'ImageSearchLabel'
      build_image_search_navigable_label nav.navigable
    end
  end

  def build_image_search_navigable_label(navigable)
    labels = ''
    site = navigable.affiliate
    if !site.force_mobile_format? || site.is_bing_image_search_enabled?
      append_navigation_label(labels,
                              link_to('Domains', site_domains_path(site)))
    end
    if site.flickr_profiles.exists?
      append_navigation_label labels,
                              link_to('Flickr', site_flickr_urls_path(site))
    end
    if site.instagram_profiles.exists?
      append_navigation_label labels,
                              link_to('Instagram',
                                      site_instagram_usernames_path(site))
    end
    if site.rss_feeds.mrss.exists?
      append_navigation_label labels,
                              link_to('MRSS', site_rss_feeds_path(site))
    end
    labels.html_safe
  end

  def append_navigation_label(labels, label)
    labels << raw('/') unless labels.blank?
    labels << label
  end

  def render_navigable_field_name_for(navigation)
    navigation.navigable.instance_of?(ImageSearchLabel) ? navigation.navigable_type.underscore : navigation.navigable_type.underscore.pluralize
  end

  def render_navigations(affiliate, search, search_params)
    if search.is_a?(SiteSearch) && search.document_collection && !search.document_collection.navigation.is_active?
      return render_navigations_for_non_navigable_document_collection(search, search_params)
    end

    return if affiliate.navigations.active.blank?

    dc = search.is_a?(SiteSearch) ? search.document_collection : nil
    rss_feed = search.is_a?(NewsSearch) ? search.rss_feed : nil

    nav_items = []
    nav_items << render_navigation_for_search_everything(search,
                                                         search_params,
                                                         rss_feed,
                                                         affiliate.default_search_label)

    affiliate.navigations.active.each do |navigation|
      navigable = navigation.navigable
      nav_items << case navigation.navigable_type
        when 'ImageSearchLabel'
          render_navigation_for_image_search(navigable,
                                             search_params,
                                             search.instance_of?(LegacyImageSearch))
        when 'DocumentCollection'
          render_navigation_for_document_collection(navigable,
                                                    search_params,
                                                    dc)
        when 'RssFeed'
          render_navigation_for_rss_feed(navigable,
                                         search_params,
                                         rss_feed)
      end
    end
    nav_html = nav_items.collect { |nav_item| content_tag(:li, nav_item.html_safe) }
    content_tag(:ul, nav_html.join("\n").html_safe, :class => 'navigations')
  end

  def render_navigations_for_non_navigable_document_collection(search, search_params)
    dc = search.document_collection
    nav_item = render_navigation_for_document_collection(dc, search_params, dc)
    content_tag(:ul, content_tag(:li, nav_item), class: 'navigations')
  end

  def render_navigation_for_search_everything(search, search_params, rss_feed, default_search_label)
    search_everything = search.instance_of?(WebSearch) || (search.is_a?(NewsSearch) && rss_feed.nil?)
    search_has_time_filters = search.is_a?(NewsSearch) && (search.since || search.until)
    default_search_path = search_has_time_filters ? news_search_path(search_params.remove(:channel, :dc)) : search_path(search_params.remove(:channel))
    link_to_unless(search_everything,
                   default_search_label,
                   default_search_path,
                   :class => 'updatable') do |everything|
      content_tag(:div, everything)
    end
  end

  def render_navigation_for_image_search(navigable, search_params, is_image_search)
    link_to_unless(is_image_search,
                   navigable.name,
                   image_search_path(search_params.remove(:channel, :tbs)),
                   :class => 'updatable') do |images|
      content_tag(:div, images)
    end
  end

  def render_navigation_for_document_collection(navigable, search_params, document_collection)
    link_to_unless((document_collection && document_collection.id == navigable.id),
                   navigable.name,
                   docs_search_path(search_params.merge(:dc => navigable.id).remove(:channel, :tbs)),
                   :class => 'updatable') do |collection_name|
      content_tag(:div, collection_name)
    end
  end

  def render_navigation_for_rss_feed(navigable, search_params, rss_feed)
    link_to_unless((rss_feed && rss_feed.id == navigable.id),
                   navigable.name,
                   news_search_path(search_params.merge(:channel => navigable.id)),
                   :class => 'updatable') do |feed_name|
      content_tag(:div, feed_name)
    end
  end
end
