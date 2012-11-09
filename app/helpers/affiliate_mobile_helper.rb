module AffiliateMobileHelper
  def render_mobile_header(affiliate)
    if affiliate.mobile_logo_file_name.present?
      link_to_if(affiliate.mobile_homepage_url.present?, image_tag(affiliate.mobile_logo.url, :alt => 'logo'), affiliate.mobile_homepage_url)
    else
      link_to_if(affiliate.mobile_homepage_url.present?, content_tag(:h1, "#{affiliate.display_name} #{I18n.t(:mobile)}", class: 'page-title'), affiliate.mobile_homepage_url)
    end
  end
end