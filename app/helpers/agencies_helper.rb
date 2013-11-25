# coding: utf-8
module AgenciesHelper
  def agency_url_matches_by_locale(result_url, agency, locale)
    agency.agency_urls.find_by_url_and_locale(result_url, locale.to_s).nil? ? false : true
  end

  def display_agency_link(result, search, affiliate, position, vertical)
    link_title = url_without_protocol(truncate_url(result['unescapedUrl']))
    tracked_click_link(h(result['unescapedUrl']), h(link_title), search, affiliate, position, search.module_tag, vertical, "class='link-to-full-url'")
  end

  def display_agency_phone_numbers(agency)
    content = ""
    content << content_tag(:li, "#{agency.phone} (#{t :agency_phone_label})") if agency.phone.present?
    content << content_tag(:li, "#{agency.toll_free_phone} (#{t :agency_toll_free_phone_label})") if agency.toll_free_phone.present?
    content << content_tag(:li, "#{agency.tty_phone} (#{t :agency_tty_phone_label})") if agency.tty_phone.present?
    content_tag :ul, content.html_safe
  end

  def display_agency_social_media_links(agency)
    list_html = ""
    Agency::SOCIAL_MEDIA_SERVICES.each do |service|
      profile_link = agency.send("#{service.downcase}_profile_link".to_sym)
      title = "#{service}#{spanish_locale? ? " (en inglés)" : ""}"
      list_html << content_tag(:li, link_to(title, profile_link, :title => title, :class => service.downcase)) unless profile_link.blank?
    end
    content_tag(:ul, list_html.html_safe, :class => 'social-media')
  end
end
