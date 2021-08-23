module RssFeedsHelper
  def rss_feed_class_hash(rss_feed)
    if rss_feed.has_errors?
      { class: 'error' }
    elsif rss_feed.has_pending?
      { class: 'warning' }
    else
      { class: 'success' }
    end
  end

  def link_to_view_rss_feed_urls(site, rss_feed)
    title = content_tag(:h1, "#{h(rss_feed.name)} #{rss_feed_properties(rss_feed)}")
    link_to rss_feed.name,
            site_rss_feed_path(site, rss_feed.id),
            class: 'modal-page-viewer-link',
            data: { modal_container: '#urls',
                    modal_title: title,
                    modal_content_selector: '.urls' }
  end

  def rss_feed_properties(rss_feed)
    if rss_feed.show_only_media_content?
      content_tag :span, '(Media RSS)', class: 'properties'
    elsif rss_feed.is_managed?
      content_tag :span, '(YouTube)', class: 'properties'
    end
  end

  def link_to_preview_rss_feed(site, rss_feed)
    params = { affiliate: site.name, channel: rss_feed.id }
    url = site.search_consumer_search_enabled? ? search_consumer_news_search_url(params) : news_search_url(params)
    link_to 'Preview', url, target: '_blank'
  end

  def list_item_with_button_to_remove_rss_feed(site, rss_feed)
    return if rss_feed.is_managed?
    path = site_rss_feed_path site, rss_feed.id
    data = { confirm: "Are you sure you wish to remove #{rss_feed.name} from this site?" }
    button = button_to 'Remove', path, method: :delete, data: data, class: 'btn btn-small'
    content_tag :li, button
  end
end
