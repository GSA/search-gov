module MobileHelper
  def mobile_header(affiliate)
    if affiliate.mobile_logo_file_name.present?
      link_to_if(affiliate.website.present?,
                 image_tag(affiliate.mobile_logo.url, alt: affiliate.display_name),
                 affiliate.website)
    else
      link_to_if(affiliate.website.present?,
                 content_tag(:h1, affiliate.display_name),
                 affiliate.website)
    end
  end

  def typeahead_query_class(affiliate)
    affiliate.is_sayt_enabled? ? 'form-control typeahead-enabled' : 'form-control'
  end

  def serp_attribution(search_module_tag)
    powered_by = I18n.t :powered_by
    if %w(BWEB IMAG).include? search_module_tag
      "#{powered_by} Bing"
    elsif %w(GWEB GIMAG).include? search_module_tag
      "#{powered_by} Google"
    else
      link_to "#{powered_by} USASearch", 'http://usasearch.howto.gov'
    end
  end

  def pagination_link_separator(page_str)
    page = page_str.to_i rescue 1
    content_tag(:span, "#{I18n.t :page} #{h params[:page]}", class: 'current_page') if page > 1
  end
end
