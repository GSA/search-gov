module NoResultsPagesHelper
  def link_to_add_new_site_no_results_pages_alt_link(title, site)
    instrumented_link_to title, new_no_results_pages_alt_link_site_no_results_pages_path(site), site.managed_no_results_pages_alt_links.length, 'site-no-results-pages-alt-link'
  end
end
