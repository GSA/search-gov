module AffiliateHelper
  def breadcrumbs(breadcrumbs)
    trail = link_to 'Dashboard', home_affiliates_path
    breadcrumbs.each { |breadcrumb| trail << ' > ' << breadcrumb }
    content_tag(:div,trail, :class => 'breadcrumb')
  end
end