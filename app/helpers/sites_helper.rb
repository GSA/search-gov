module SitesHelper
  def render_site_success_flash_message
    if flash.present?
      html = flash.map do |key, msg|
        content = button_tag '×', class: 'close', 'data-dismiss' => 'alert'
        content << msg
        content_tag(:div, content.html_safe, class: "alert alert-#{key}")
      end
      html.join('\n').html_safe
    end
  end

  def render_site_help_link(help_link)
    link_to('Help?', help_link.help_page_url, class: 'help-link menu') if help_link
  end

  def site_nav_css_class_hash(current_nav, nav_name)
    current_nav == nav_name ? { class: 'active'} : {}
  end

  def site_locale(affiliate)
    affiliate.locale == :es ? 'Spanish' : 'English'
  end
end
