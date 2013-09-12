module CssPropertiesHelper
  def preview_page_css_hash(css_property_hash)
    internal_name_css_hash = { page_background_color: 'background-color' }
    style_hash(css_property_hash, internal_name_css_hash)
  end

  def preview_content_class_hash(site)
    site.show_content_border? ? { class: 'serp-content-show-border' } : {}
  end

  def preview_content_css_hash(site)
    internal_name_css_hash = { content_background_color: 'background-color',
                               content_border_color: 'border-color' }
    hash = style_hash(site.css_property_hash, internal_name_css_hash)
    if site.show_content_box_shadow?
      hash[:style] << box_shadow_css_style(
          site_css_property(site.css_property_hash, :content_box_shadow_color))
    end
    hash
  end

  def box_shadow_css_style(color)
    shadow = "0 0 5px #{color}"
    style = "-webkit-box-shadow: #{shadow};"
    style << "-moz-box-shadow: #{shadow};"
    style << "box-shadow: #{shadow};"
    style
  end

  def preview_search_button_css_hash(css_property_hash)
    internal_name_css_hash = { search_button_background_color: %w(background-color border-color),
                               search_button_text_color: 'color' }
    style_hash(css_property_hash, internal_name_css_hash)
  end

  def preview_results_css_hash(css_property_hash)
    internal_name_css_hash = { font_family: 'font-family' }
    style_hash(css_property_hash, internal_name_css_hash)
  end

  def preview_active_sidebar_item_css_hash(css_property_hash)
    internal_name_css_hash = { left_tab_text_color: 'color' }
    style_hash(css_property_hash, internal_name_css_hash)
  end

  def preview_result_title_css_hash(css_property_hash)
    internal_name_css_hash = { title_link_color: 'color' }
    style_hash(css_property_hash, internal_name_css_hash)
  end

  def preview_visited_result_title_css_hash(css_property_hash)
    internal_name_css_hash = { visited_title_link_color: 'color' }
    style_hash(css_property_hash, internal_name_css_hash)
  end

  def preview_result_url_css_hash(css_property_hash)
    internal_name_css_hash = { url_link_color: 'color' }
    style_hash(css_property_hash, internal_name_css_hash)
  end

  def preview_description_css_hash(css_property_hash)
    internal_name_css_hash = { description_text_color: 'color' }
    style_hash(css_property_hash, internal_name_css_hash)
  end

  def style_hash(css_property_hash, internal_name_css_hash)
    style = ''
    internal_name_css_hash.each do |internal_name, css_properties|
      css_value = site_css_property(css_property_hash, internal_name)
      css_properties = [css_properties] unless css_properties.respond_to?(:each)
      css_properties.each do |css_property|
        style << "#{css_property}: #{css_value};"
      end
    end
    { style: style }
  end
end
