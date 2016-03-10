module Admin::SearchConsumerHelper
          
    def selected_template_dropdown_options(affiliate)
      dropdown_options = ''
      affiliate.templates.available.each do |active_template|
        if affiliate.template.type == active_template.type
          dropdown_options +="<option selected='selected' value='#{affiliate.template.type}'>#{affiliate.template.class::HUMAN_READABLE_NAME}</option>"
        else
          dropdown_options += "<option value='#{active_template.type}'>#{active_template.class::HUMAN_READABLE_NAME}</option>"  
        end
      end
      return dropdown_options.html_safe
    end

end
    