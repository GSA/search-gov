# frozen_string_literal: true

module VisualDesignHelper
  def render_affiliate_visual_design_value(visual_design_json, property)
    if visual_design_json.present? && visual_design_json[property.to_s]
      visual_design_json[property.to_s]
    else
      Affiliate::DEFAULT_VISUAL_DESIGN[property]
    end
  end

  def render_logo_alt_text(logo_metadata)
    if logo_metadata.present? && logo_metadata.key?('alt_text')
      logo_metadata['alt_text']
    else
      t('sites.visual_designs.image_assets.logo', scope: 'admin_center')
    end
  end

  def link_to_add_primary_header_link(title, site)
    instrumented_link_to(title,
                         new_link_site_visual_design_path(site),
                         site.primary_header_links.length,
                         'site-primary-header-link')
  end

  def link_to_add_secondary_header_link(title, site)
    instrumented_link_to(title,
                         new_link_site_visual_design_path(site),
                         site.secondary_header_links.length,
                         'site-secondary-header-link')
  end

  def link_to_add_footer_link(title, site)
    instrumented_link_to(title,
                         new_link_site_visual_design_path(site),
                         site.footer_links.length,
                         'site-footer-link')
  end

  def link_to_add_identifier_link(title, site)
    instrumented_link_to(title,
                         new_link_site_visual_design_path(site),
                         site.identifier_links.length,
                         'site-identifier-link')
  end
end
