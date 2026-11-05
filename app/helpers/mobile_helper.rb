require 'benchmark'
module MobileHelper
  ADVANCED_SEARCH_FILETYPE_OPTIONS = [[I18n.t(:advanced_search_file_type_all_format_label), nil],
                                      ['Adobe PDF', 'pdf'],
                                      ['Microsoft Excel', 'xls'],
                                      ['Microsoft PowerPoint', 'ppt'],
                                      ['Microsoft Word', 'doc'],
                                      [I18n.t(:advanced_search_file_type_txt_format_label), 'txt']].freeze

  def search_results_by_text(_module_tag)
    I18n.t(:powered_by) << ' Search.gov'
  end

  def serp_attribution(_search_module_tag)
    render partial: 'searches/powered_by_digital_gov_search'
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

  def pagination_link_separator(page_str)
    content_tag(:span, "#{I18n.t :page} #{page_str}", class: 'current_page')
  end

  def related_sites_dropdown_label(label)
    label || I18n.t(:'searches.related_sites')
  end
end
