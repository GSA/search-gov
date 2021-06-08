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
end
