module NavigationsHelper
  def link_to_navigable(navigable)
    case navigable.class.name
    when 'DocumentCollection' then link_to('Collection', [navigable.affiliate, navigable])
    when 'RssFeed' then link_to('RSS', [navigable.affiliate, navigable])
    when 'ImageSearchLabel' then 'Bing'
    end
  end

  def render_navigable_field_name_for(navigation)
    navigation.navigable.instance_of?(ImageSearchLabel) ? navigation.navigable_type.underscore : navigation.navigable_type.underscore.pluralize
  end

  def render_navigations(navigations, search_params, left_nav_tag, is_image_search, dc_and_feed_hash)
    content = []
    navigations.each do |navigation|
      navigable = navigation.navigable
      html = case navigation.navigable_type
             when 'DocumentCollection'
               render_document_collection_navigation(navigable, search_params, left_nav_tag, dc_and_feed_hash[:document_collection])
             when 'ImageSearchLabel'
               render_image_search_label_navigation(navigable, search_params, left_nav_tag, is_image_search)
             when 'RssFeed'
               render_rss_feed_navigation(navigable, search_params, left_nav_tag, dc_and_feed_hash[:rss_feed])
             end
      content << content_tag(:li, html.html_safe)
    end
    content.join("\n").html_safe
  end

  def render_document_collection_navigation(navigable, search_params, left_nav_tag, document_collection)
    link_to_unless((document_collection && document_collection.id == navigable.id),
                   navigable.name,
                   docs_search_path(search_params.merge(:dc => navigable.id).remove(:channel, :tbs)),
                   :class => 'updatable') do |collection_name|
      content_tag left_nav_tag, collection_name
    end
  end

  def render_image_search_label_navigation(navigable, search_params, left_nav_tag, is_image_search)
    link_to_unless(is_image_search, navigable.name, image_search_path(search_params.remove(:channel, :tbs)), :class => 'updatable') do |images|
      content_tag(left_nav_tag, images)
    end
  end

  def render_rss_feed_navigation(navigable, search_params, left_nav_tag, rss_feed)
    link_to_unless((rss_feed && rss_feed.id == navigable.id),
                   navigable.name,
                   news_search_path(search_params.merge(:channel => navigable.id)),
                   :class => 'updatable') do |feed_name|
      content_tag(left_nav_tag, feed_name)
    end
  end
end
