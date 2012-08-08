module NavigationsHelper
  def link_to_navigable(navigable)
    case navigable.class.name
      when 'DocumentCollection'
        link_to('Collection', [navigable.affiliate, navigable])
      when 'RssFeed'
        link_to('RSS', [navigable.affiliate, navigable])
      when 'ImageSearchLabel'
        'Bing'
    end
  end

  def render_navigable_field_name_for(navigation)
    navigation.navigable.instance_of?(ImageSearchLabel) ? navigation.navigable_type.underscore : navigation.navigable_type.underscore.pluralize
  end

  def render_navigations(affiliate, search, search_params)
    return if affiliate.navigations.active.blank?

    dc = search.is_a?(OdieSearch) ? search.document_collection : nil
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

  def render_navigation_for_search_everything(search, search_params, rss_feed, default_search_label)
    search_everything = (search.instance_of?(WebSearch) or
      (search.is_a?(NewsSearch) && rss_feed.nil?))
    default_search_path = search_params[:tbs] ? news_search_path(search_params.remove(:channel, :dc)) : search_path(search_params.remove(:channel))
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

  def dublin_core_attribute(affiliate, facet_name)
    mapping = affiliate.dublin_core_mappings[facet_name] || facet_name.to_s.titleize
    content_tag(:h4, mapping, :id => 'dublin_core_filter')
  end
end
