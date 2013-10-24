module SitesHelper
  def site_select
    sites = current_user.affiliates.map { |p| ["#{p.display_name} (#{p.name})", p.id] }
    select_options = {include_blank: true, selected: nil}
    html_options = {id: 'site_select', class: 'site-select'}
    select 'site', 'id', sites, select_options, html_options
  end

  def daily_snapshot_toggle(membership)
    return if membership.nil?
    description_class = 'description label off-screen-text'
    if membership.gets_daily_snapshot_email?
      button_class = 'btn disabled'
      description_class << ' label-warning'
      verb = 'Stop sending'
    else
      button_class = 'btn'
      verb = 'Send'
    end
    title = "#{verb} me today's snapshot as a daily email"
    wrapper_options = {id: 'envelope-snapshot-toggle',
                       'data-toggle' => 'tooltip',
                       'data-original-title' => title}

    form_for membership, as: :membership, url: site_membership_path(@site, membership), method: :put, html: wrapper_options do
      button_tag class: button_class, type: :submit do
        inner_html = stacked_envelope
        inner_html << content_tag(:span, title, class: description_class)
        if membership.gets_daily_snapshot_email?
          content_tag :div, inner_html, class: 'btn disabled'
        else
          inner_html
        end
      end
    end
  end

  def site_pin(site)
    if current_user.default_affiliate_id != site.id
      button_to_enabled_pin_site(site)
    else
      button_to_disabled_pin_site
    end
  end

  def button_to_enabled_pin_site(site)
    title = 'Set as my default site'
    wrapper_options = {id: 'pin-site',
                       'data-toggle' => 'tooltip',
                       'data-original-title' => title}

    form_for site, as: :site, url: pin_site_path(site), html: wrapper_options do
      button_tag class: 'btn', type: :submit do
        inner_html = stacked_pushpin
        inner_html << content_tag(:span, title, class: 'description label off-screen-text')
      end
    end
  end

  def button_to_disabled_pin_site
    title = 'Your default site'
    wrapper_options = {id: 'pin-site',
                       'data-toggle' => 'tooltip',
                       'data-original-title' => title}
    content_tag :div, wrapper_options do
      inner_html = stacked_pushpin
      inner_html << content_tag(:span, title, class: 'description label label-warning off-screen-text')
      content_tag :div, inner_html, class: 'btn disabled'
    end
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
    nav_controllers.include?(controller_name) ? {class: 'active'} : {}
  end

  def site_dashboard_controllers
    %w(settings sites users)
  end

  def site_activate_search_controllers
    %w(embed_codes api_instructions)
  end

  def site_analytics_controllers
    %w(queries clicks monthly_reports raw_logs_accesses third_party_tracking_requests click_queries query_clicks)
  end

  def site_manage_content_controllers
    %w(boosted_contents contents document_collections domains excluded_urls
       flickr_profiles indexed_documents rss_feeds site_feed_urls
       twitter_profiles youtube_profiles featured_collections)
  end

  def site_manage_display_controllers
    %w(header_and_footers displays font_and_colors image_assets)
  end

  def list_item_with_link_to_current_help_page
    help_link = HelpLink.lookup(request, controller.action_name)
    content_tag(:li, link_to('Help?', help_link.help_page_url, class: 'help-link menu')) if help_link
  end

  def site_nav_css_class_hash(*nav_names)
    nav_names.include?(controller_name) ? {class: 'active'} : {}
  end

  def site_locale(site)
    site.locale == 'es' ? 'Spanish' : 'English'
  end

  def render_preview_links(title, site, options = {}, target = 'preview-frame')
    return if options[:staged].present? and !site.has_staged_content?

    list_item_options = options[:m].blank? &&
      ((site.has_staged_content? and options[:staged].present?) ||
        !site.has_staged_content?) ? {class: 'active'} : {}

    content_tag :li, list_item_options do
      link_options = {affiliate: site.name, query: 'gov', external_tracking_code_disabled: true}.merge options
      link_to title, search_path(link_options), target: target
    end
  end

  def link_to_add_new_boosted_content_keyword(title, site, boosted_content)
    link_to title,
            new_keyword_site_best_bets_texts_path(site),
            remote: true,
            data: {params: {index: boosted_content.boosted_content_keywords.length}},
            id: 'new-keyword-trigger'
  end

  def link_to_add_new_featured_collection_keyword(title, site, featured_collection)
    link_to title,
            new_keyword_site_best_bets_graphics_path(site),
            remote: true,
            data: {params: {index: featured_collection.featured_collection_keywords.length}},
            id: 'new-keyword-trigger'
  end

  def preview_search_path_options(site)
    default_options = {affiliate: site.name,
                       external_tracking_code_disabled: true,
                       query: 'gov'}
    default_options[:staged] = '1' if site.has_staged_content?
    default_options
  end
end
