module NavigationsHelper
  def configurable_navigations(site)
    if site.force_mobile_format? && site.flickr_profiles.blank?
      site.navigations.reject { |n| n.navigable.is_a?(ImageSearchLabel) }
    else
      site.navigations
    end
  end

  def link_to_site_navigable(navigable)
    case navigable.class.name
    when 'DocumentCollection'
      link_to('Collection', edit_site_collection_path(navigable.affiliate, navigable))
    when 'RssFeed'
      if navigable.is_managed?
        link_to('YouTube', site_youtube_usernames_path(navigable.owner))
      else
        link_to('RSS', edit_site_rss_feed_path(navigable.owner, navigable))
      end
    when 'ImageSearchLabel'
      content = link_to 'Domains', site_domains_path(navigable.affiliate)
      if navigable.affiliate.flickr_profiles.exists?
        content << raw('/')
        content << link_to('Flickr', site_flickr_urls_path(navigable.affiliate))
      end
      content
    end
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
                                             search.instance_of?(ImageSearch))
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
