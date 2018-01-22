require 'benchmark'
module MobileHelper
  DEFAULT_FONT_STYLESHEET_LINK = 'https://fonts.googleapis.com/css?family=Maven+Pro:400,700'.freeze

  ADVANCED_SEARCH_FILETYPE_OPTIONS = [[I18n.t(:advanced_search_file_type_all_format_label), nil],
                                      ['Adobe PDF', 'pdf'],
                                      ['Microsoft Excel', 'xls'],
                                      ['Microsoft PowerPoint', 'ppt'],
                                      ['Microsoft Word', 'doc'],
                                      [I18n.t(:advanced_search_file_type_txt_format_label), 'txt']].freeze

  def advanced_search?
    controller.action_name == 'advanced'
  end

  def dropdown_wrapper(partial, html, dropdown_id, dropdown_label)
    render partial: partial,
           locals: { html: html, id: dropdown_id, dropdown_label: dropdown_label }
  end

  def font_stylesheet_link_tag(affiliate)
    stylesheet_link_tag(DEFAULT_FONT_STYLESHEET_LINK) if FontFamily.default?(affiliate.css_property_hash[:font_family])
  end

  def mobile_header(affiliate)
    css_classes = 'header-logo'
    logo_url = affiliate.mobile_logo.url rescue nil if affiliate.mobile_logo_file_name.present?

    if logo_url.present?
      logo_alt = affiliate.logo_alt_text || affiliate.display_name
      logo_class = LogoAlignment::get_logo_alignment_class affiliate
      css_classes << ' ' << logo_class if logo_class

      html = link_to_if(affiliate.website.present?,
                        image_tag(logo_url, alt: logo_alt),
                        affiliate.website, tabindex: 1)
    else
      html = link_to_if(affiliate.website.present?,
                        content_tag(:div, affiliate.display_name, class: 'header-text'),
                        affiliate.website, tabindex: 1)
      css_classes << ' text'
    end
    content_tag(:div, html, class: css_classes)
  end

  def header_tagline_logo(affiliate)    
    logo_url = affiliate.header_tagline_logo.url rescue nil if affiliate.header_tagline_logo_file_name.present?
    logo_alt = "header tagline logo - " + affiliate.header_tagline    

    if logo_url.present?      
       html = link_to_if(affiliate.header_tagline_url.present?, 
                      image_tag(logo_url, alt: logo_alt, id: 'header-tagline-logo'),
                      affiliate.header_tagline_url, tabindex: 1)
       # content_tag(:div, html, class: )    
    end    
  end

  def typeahead_query_class(affiliate)
    affiliate.is_sayt_enabled? ? 'form-control typeahead-enabled' : 'form-control'
  end

  def search_results_by_text(module_tag)
    provider = case module_tag
      when 'AIMAG', 'AWEB', 'BWEB', 'IMAG' then ' Bing'
      when 'GWEB', 'GIMAG' then ' Google'
      else ' Search.gov'
      end
    I18n.t(:powered_by) << provider
  end

  def serp_attribution(search_module_tag)
    powered_by = I18n.t :powered_by
    if %w(AIMAG AWEB BWEB IMAG).include? search_module_tag
      bing_class = %w(AIMAG AWEB).include?(search_module_tag) ? 'azure' : 'bing'
      content_tag(:div, class: bing_class) do
        (powered_by << content_tag(:span, ' Bing')).html_safe
      end
    elsif %w(GWEB GIMAG).include? search_module_tag
      content_tag(:span, "#{powered_by} Google")
    else
      render partial: 'searches/powered_by_digital_gov_search'
    end
  end

  def html_class_hash(language)
    hash = { lang: language.code }
    hash.merge!(dir: 'rtl') if language.rtl
    hash
  end

  def body_class_hash(site)
    css_classes = []
    page_background_color = site_css_color_property(site.css_property_hash, :page_background_color)
    css_classes << 'assign-default-bg' if page_background_color =~ /^#FFF(FFF)?$/i
    css_classes << 'menu-button-left' if site.css_property_hash[:menu_button_alignment].eql?('left')
    css_classes.present? ? { class: css_classes.join(' ') } : {}
  end

  def matching_site_limits(search, search_params)
    return if search.matching_site_limits.blank?
    matching_site_query = content_tag :span, search.query
    matching_sites = content_tag :span, search.matching_site_limits.join(', ')

    query_from_all_sites_link = link_to search_path(search_params.except(:sitelimit)) do
      raw I18n.t :'searches.site_limits.query_from_all_sites',
                 query: content_tag(:span, search.query)
    end

    render partial: 'searches/matching_site_limits',
           locals: {
               query_and_matching_sites_hash: {
                   query: matching_site_query, matching_sites: matching_sites },
               query_from_all_sites_hash: {
                   query_from_all_sites: query_from_all_sites_link }
           }
  end

  def pagination_link_separator(page_str)
    content_tag(:span, "#{I18n.t :page} #{page_str}", class: 'current_page')
  end

  def related_sites_dropdown_label(label)
    label || I18n.t(:'searches.related_sites')
  end
end
