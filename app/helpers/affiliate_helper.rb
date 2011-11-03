module AffiliateHelper
  def affiliate_center_breadcrumbs(crumbs)
    aff_breadcrumbs =
      [link_to("Affiliate Program", affiliates_path), link_to("Affiliate Center",home_affiliates_path), crumbs]
    breadcrumbs(aff_breadcrumbs.flatten)
  end

  def site_wizard_header(current_step)
    steps = {:edit_contact_information => 0, :new_site_information => 1, :get_the_code => 2}
    step_contents = ["Step 1. Enter contact information", "Step 2. Set up site", "Step 3. Get the code"]
    image_tag("site_wizard_step_#{steps[current_step] + 1}.png", :alt => "#{step_contents[steps[current_step]]}")
  end

  def render_choose_site_templates(affiliate)
    templates = AffiliateTemplate.all.sort_by(&:name).collect do |template|
      checked = affiliate.staged_affiliate_template_id? ? affiliate.staged_affiliate_template_id == template.id : (template.name == 'Default')
      content = ''
      content << radio_button(:affiliate, :staged_affiliate_template_id, template.id, :checked => checked)
      content << label(:affiliate, "staged_affiliate_template_id_#{template.id}", template.name)
      content << image_tag("affiliate_template_#{template.name.downcase.gsub(' ', '_').underscore}.png")
      content_tag :div, raw(content), :class => 'affiliate-template'
    end
    templates.join
  end

  def render_last_crawl_status(indexed_document)
    return indexed_document.last_crawl_status if indexed_document.last_crawl_status == IndexedDocument::OK_STATUS or indexed_document.last_crawl_status.blank?

    content = ''
    dialog_id = "crawled-url-error-message-#{indexed_document.id}"
    content << link_to('Error', '#', :class => 'crawled-url-dialog-link', :dialog_id => dialog_id)
    content << link_to(content_tag(:span, nil, :class => 'ui-icon ui-icon-newwin'), '#', :class => 'crawled-url-dialog-link', :dialog_id => dialog_id)
    error_message_text = h(indexed_document.url)
    error_message_text << tag(:br)
    error_message_text << h(indexed_document.last_crawl_status)
    content << content_tag(:div, error_message_text.html_safe, :class => 'crawled-url-error-message', :id => dialog_id)
    content.html_safe
  end
end
