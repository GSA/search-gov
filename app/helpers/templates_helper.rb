module TemplatesHelper
  def generate_template_font_dropdown(default_font, font_family)
    font_dropdown_options = ''
    font_family.to_s.split(", ").each do |font|
      if default_font == font
        font_dropdown_options +="<option selected='selected' value='#{default_font}'>#{default_font}</option>"
      else
        font_dropdown_options += "<option value='#{font}'>#{font}</option>"  
      end
    end
    return font_dropdown_options.html_safe
  end
end