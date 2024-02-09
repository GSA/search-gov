# frozen_string_literal: true

module VisualDesignHelper
  def render_affiliate_visual_design_value(visual_design_json, property)
    property = property.to_s
    visual_design_json[property] || Affiliate::DEFAULT_VISUAL_DESIGN[property]
  end

  def show_results_format?(site)
    (site.gets_i14y_results || site.gets_blended_results || site.search_engine == 'SearchGov') &&
      site.search_engine != 'BingV7'
  end

  def render_logo_alt_text(logo_metadata)
    if logo_metadata.present? && logo_metadata.key?('alt_text')
      logo_metadata['alt_text']
    else
      t('sites.visual_designs.image_assets.logo', scope: 'admin_center')
    end
  end

  def link_to_add_link(title, site, attribute)
    link_to(title,
            new_site_link_path(site),
            remote: true,
            data: { params: { position: site.send(attribute).size, type: attribute.camelize.singularize } },
            id: "new-#{attribute.dasherize}-trigger")
  end
end
