module SitesHelper
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

  def link_to_current_help_page
    help_link_key = HelpLink.sanitize_request_path request.fullpath
    help_link = HelpLink.find_by_request_path help_link_key
    link_to('Help?', help_link.help_page_url, class: 'help-link menu') if help_link
  end

  def site_nav_css_class_hash(current_nav, nav_name)
    current_nav == nav_name ? { class: 'active'} : {}
  end

  def site_locale(affiliate)
    affiliate.locale == :es ? 'Spanish' : 'English'
  end
end
