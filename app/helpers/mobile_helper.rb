module MobileHelper
  DEFAULT_FONT_STYLESHEET_LINK = 'https://fonts.googleapis.com/css?family=Maven+Pro:400,700'.freeze

  def font_stylesheet_link_tag(affiliate)
    stylesheet_link_tag(DEFAULT_FONT_STYLESHEET_LINK) if FontFamily.default?(affiliate.css_property_hash[:font_family])
  end

  def mobile_header(affiliate)
    css_classes = 'logo'
    logo_url = affiliate.mobile_logo.url rescue nil if affiliate.mobile_logo_file_name.present?

    if logo_url.present?
      html = link_to_if(affiliate.website.present?,
                        content_tag(:h1, image_tag(logo_url, alt: affiliate.display_name)),
                        affiliate.website, tabindex: 1)
    else
      html = link_to_if(affiliate.website.present?,
                        content_tag(:h1, affiliate.display_name),
                        affiliate.website, tabindex: 1)
      css_classes << ' text'
    end
    content_tag(:div, html, class: css_classes)
  end

  def typeahead_query_class(affiliate)
    affiliate.is_sayt_enabled? ? 'form-control typeahead-enabled' : 'form-control'
  end

  def serp_attribution(search_module_tag)
    powered_by = I18n.t :powered_by
    if %w(BWEB IMAG).include? search_module_tag
      content_tag(:div, class: 'bing') do
        (powered_by << content_tag(:span, 'Bing')).html_safe
      end
    elsif %w(GWEB GIMAG).include? search_module_tag
      content_tag(:span, "#{powered_by} Google")
    else
      render partial: 'searches/powered_by_digital_gov_search'
    end
  end

  def matching_site_limits(search, search_params)
    return if search.matching_site_limits.blank?
    search_matching_sites_link = link_to search.query, search_path(search_params)
    matching_sites = content_tag(:span, search.matching_site_limits.join(', '))
    search_all_sites_link = link_to search.query, search_path(search_params.except(:sitelimit))
    render partial: 'searches/matching_site_limits',
           locals: {
               search_matching_sites_hash: {
                   query: search_matching_sites_link, matching_sites: matching_sites },
               search_all_sites_hash: { query: search_all_sites_link }
           }
  end

  def pagination_link_separator(page_str)
    page = page_str.to_i rescue 1
    content_tag(:span, "#{I18n.t :page} #{h params[:page]}", class: 'current_page') if page > 1
  end
end
