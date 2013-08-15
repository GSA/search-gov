module SitesHelper
  def site_select
    sites = current_user.affiliates.map { |p| [ "#{p.display_name} (#{p.name})", p.id ] }
    select_options = { include_blank: true, selected: nil }
    html_options = { id: 'site_select', class: 'site-select' }
    select 'site', 'id', sites, select_options, html_options
  end

  def content_for_site_page_title(site, title)
    content_for :title, "#{title} - #{site.display_name}"
  end

  def render_site_flash_message
    if flash.present?
      html = flash.map do |key, msg|
        content = button_tag '×', class: 'close', 'data-dismiss' => 'alert'
        content << msg
        content_tag(:div, content.html_safe, class: "alert alert-#{key}")
      end
      html.join('\n').html_safe
    end
  end

  def main_nav_item(title, path, icon, nav_controllers, link_options = {})
    link_options.reverse_merge! 'data-toggle' => 'tooltip', 'data-original-title' => title
    item_content = link_to path, link_options do
      inner_html = content_tag :i, nil, class: "#{icon} icon-2x"
      inner_html << content_tag(:span, title, class: 'description')
    end
    content_tag :li, item_content, main_nav_css_class_hash(nav_controllers)
  end

  def main_nav_css_class_hash(nav_controllers)
    nav_controllers.include?(controller_name) ? { class: 'active' } : {}
  end

  def site_dashboard_controllers
    %w(settings sites users)
  end

  def site_manage_content_controllers
    %w(boosted_contents contents domains flickr_profiles rss_feeds
        twitter_profiles youtube_profiles)
  end

  def list_item_with_link_to_current_help_page
    help_link_key = HelpLink.sanitize_request_path request.fullpath
    help_link = HelpLink.find_by_request_path help_link_key
    content_tag(:li, link_to('Help?', help_link.help_page_url, class: 'help-link menu')) if help_link
  end

  def site_nav_css_class_hash(nav_name)
    nav_name == controller_name ? { class: 'active'} : {}
  end

  def site_locale(site)
    site.locale == :es ? 'Spanish' : 'English'
  end

  def render_preview_links(title, site, options = {}, target = 'preview-frame')
    return if options[:staged].present? and !site.has_staged_content?

    list_item_options = options[:m].blank? &&
        ((site.has_staged_content? and options[:staged].present?) ||
        !site.has_staged_content?) ? { class: 'active' } : {}

    content_tag :li, list_item_options do
      link_options = { affiliate: @site.name, query: 'gov', external_tracking_code_disabled: true }.merge options
      link_to title, search_path(link_options), target: target
    end
  end

  def link_to_add_new_boosted_content_keyword(title, site, boosted_content)
    link_to title,
            new_keyword_site_best_bets_texts_path(site),
            remote: true,
            data: { params: { index: boosted_content.boosted_content_keywords.length } },
            id: 'new-keyword-trigger'
  end

  def link_to_add_new_rss_feed_url(title, site, rss_feed)
    link_to title,
            new_url_site_rss_feeds_path(site),
            remote: true,
            data: { params: { index: rss_feed.rss_feed_urls.length } },
            id: 'new-url-trigger'
  end
end
