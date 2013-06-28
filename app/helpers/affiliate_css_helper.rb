module AffiliateCssHelper
  def render_affiliate_css_property_value(css_property_hash, property)
    css_property_hash[property].blank? ? Affiliate::DEFAULT_CSS_PROPERTIES[property] : css_property_hash[property]
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
