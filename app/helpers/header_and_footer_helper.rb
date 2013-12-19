module HeaderAndFooterHelper
  def save_header_footer_button(form, site)
    if site.staged_uses_managed_header_footer? && site.uses_managed_header_footer?
      form.submit 'Save', class: 'btn disabled submit disabled', disabled: true
    else
      form.submit 'Save', class: 'btn btn-primary submit'
    end
  end

  def link_to_add_new_site_header_link(title, site)
    instrumented_link_to title, new_header_link_site_header_and_footer_path(site), site.managed_header_links.length, 'site-header-link'
  end

  def link_to_add_new_site_footer_link(title, site)
    instrumented_link_to title, new_footer_link_site_header_and_footer_path(site), site.managed_footer_links.length, 'site-footer-link'
  end

  def save_for_preview_button(form, site)
    if site.staged_uses_managed_header_footer? &&
        (site.staged_header.present? || site.staged_footer.present?)
      form.submit 'Save for Preview', class: 'btn btn-primary submit'
    else
      form.submit 'Save for Preview', class: 'btn submit disabled', disabled: true
    end
  end

  def make_live_button(form, site)
    if site.has_staged_content? || site.uses_managed_header_footer?
      form.submit 'Make Live', class: 'submit btn-flat', id: 'make-live'
    else
      form.submit 'Make Live', class: 'submit btn-flat disabled', disabled: true, id: 'make-live'
    end
  end
end
