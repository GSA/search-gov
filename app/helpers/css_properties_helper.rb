# frozen_string_literal: true

module CssPropertiesHelper
  def preview_search_button_css_hash(css_property_hash)
    internal_name_css_hash = { search_button_background_color: %w[background-color border-color],
                               search_button_text_color: 'color' }
    style_hash(css_property_hash, internal_name_css_hash)
  end

  def style_hash(css_property_hash, internal_name_css_hash)
    style = +''
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
