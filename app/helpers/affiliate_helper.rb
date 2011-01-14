module AffiliateHelper
  def breadcrumbs(breadcrumbs)
    trail = link_to 'Dashboard', home_affiliates_path
    breadcrumbs.each { |breadcrumb| trail << ' > ' << breadcrumb }
    content_tag(:div,trail, :class => 'breadcrumb')
  end

  def affiliate_template_options(affiliate)
    options = "<option value=\"\">Default</option>"
    options << "<optgroup label = \"All Styles\">"
    template_options = AffiliateTemplate.all.sort_by(&:name).collect {|template| ["#{template.name} (#{template.description})", template.id]}
    options << options_for_select(template_options, :selected => affiliate.affiliate_template_id)
    options << "</optgroup>"
    options
  end
end
