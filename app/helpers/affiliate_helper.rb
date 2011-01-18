module AffiliateHelper
  def affiliate_center_breadcrumbs(crumbs)
    aff_breadcrumbs =
      [link_to("Affiliate Program", affiliates_path), link_to("Affiliate Center",home_affiliates_path), crumbs]
    breadcrumbs(aff_breadcrumbs.flatten)
  end

  def breadcrumbs(breadcrumbs)
    trail = link_to('USASearch', program_path)
    breadcrumbs.each { |breadcrumb| trail << ' > ' << breadcrumb }
    content_tag(:div,trail, :class => 'breadcrumb')
  end

  def affiliate_template_options(affiliate)
    options = "<option value=\"\">Default</option>"
    options << "<optgroup label = \"All Styles\">"
    template_options = AffiliateTemplate.all.sort_by(&:name).collect {|template| ["#{template.name} (#{template.description})", template.id]}
    options << options_for_select(template_options, :selected => affiliate.staged_affiliate_template_id)
    options << "</optgroup>"
    options
  end
end
