module AffiliateCssHelper
  def color_picker_component(form, property, css_property_hash, data)
    data[:color] = site_css_color_property(css_property_hash, property)
    data[:provide] = 'colorpicker'
    data['default-color'] = Affiliate::THEMES[:default][property]

    value = css_property_hash[property]
    value ||= Affiliate::THEMES[:default][property]
    inner_html = content_tag :div do
      form.text_field property, value: value
    end

    inner_html << content_tag(:span, class: 'add-on add-on-colorpicker') do
      content_tag :i
    end

    content_tag(:div, class: 'input-append color', data: data) { inner_html }
  end

  def render_affiliate_css_property_value(css_property_hash, property)
    if property.to_s =~ /color/i
      site_css_color_property(css_property_hash, property)
    else
      css_property_hash[property].blank? ? Affiliate::DEFAULT_CSS_PROPERTIES[property] : css_property_hash[property]
    end
  end
  alias_method :site_css_property, :render_affiliate_css_property_value

  def site_css_color_property(css_property_hash, property)
    value = css_property_hash[property]
    value =~ /^#([0-9A-F]{3}|[0-9A-F]{6})$/i ? value : Affiliate::DEFAULT_CSS_PROPERTIES[property]
  end

  def render_managed_header_css_property_value(managed_header_css_properties, property, check_for_nil = true)
    if check_for_nil and managed_header_css_properties.nil? || managed_header_css_properties[property].nil?
      Affiliate::DEFAULT_MANAGED_HEADER_CSS_PROPERTIES[property]
    elsif !check_for_nil and managed_header_css_properties.blank? || managed_header_css_properties[property].blank?
      Affiliate::DEFAULT_MANAGED_HEADER_CSS_PROPERTIES[property]
    else
      managed_header_css_properties[property]
    end
  end
end
