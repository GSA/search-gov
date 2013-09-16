module AffiliateMobileHelper
  def render_mobile_header(affiliate)
    if affiliate.mobile_logo_file_name.present?
      link_to_if(affiliate.website.present?,
                 image_tag(affiliate.mobile_logo.url, alt: affiliate.display_name),
                 affiliate.website)
    else
      link_to_if(affiliate.website.present?,
                 content_tag(:h1, "#{affiliate.display_name} #{I18n.t(:mobile)}", class: 'page-title'),
                 affiliate.website)
    end
  end
end
