# frozen_string_literal: true

module HeaderAndFooterHelper
  def link_to_add_new_site_header_link(title, site)
    instrumented_link_to title, new_header_link_site_header_and_footer_path(site), site.managed_header_links.length, 'site-header-link'
  end

  def link_to_add_new_site_footer_link(title, site)
    instrumented_link_to title, new_footer_link_site_header_and_footer_path(site), site.managed_footer_links.length, 'site-footer-link'
  end
end
