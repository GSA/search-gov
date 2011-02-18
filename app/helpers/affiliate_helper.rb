module AffiliateHelper
  def affiliate_center_breadcrumbs(crumbs)
    aff_breadcrumbs =
      [link_to("Affiliate Program", affiliates_path), link_to("Affiliate Center",home_affiliates_path), crumbs]
    breadcrumbs(aff_breadcrumbs.flatten)
  end

  def affiliate_template_options(affiliate)
    options = "<option value=\"\">Default</option>"
    options << "<optgroup label = \"All Styles\">"
    template_options = AffiliateTemplate.all.sort_by(&:name).collect {|template| ["#{template.name} (#{template.description})", template.id]}
    options << options_for_select(template_options, :selected => affiliate.staged_affiliate_template_id)
    options << "</optgroup>"
    options
  end

  def site_wizard_header(current_step)
    steps = [:edit_contact_information, :new_site_information, :get_the_code]
    step_contents = ["Step 1. Enter contact information", "Step 2. Set up site", "Step 3. Get the code"]
    header = ''
    steps.each_with_index do |step, index|
      if step == current_step
        header << content_tag('span', step_contents[index], :class => "step current_step")
      else
        header << content_tag('span', step_contents[index], :class => "step")
      end
    end
    header
  end
end
