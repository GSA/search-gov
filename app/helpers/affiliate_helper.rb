module AffiliateHelper
  def render_embed_code_javascript(affiliate)
    embed_code = <<-JS
      var usasearch_config = { siteHandle:"#{affiliate.name}" };

      var script = document.createElement("script");
      script.type = "text/javascript";
      script.src = "//#{request.host_with_port}/javascripts/remote.loader.js";
      document.getElementsByTagName("head")[0].appendChild(script);
    JS
    javascript_tag embed_code
  end

  # deprecated - Search Consumer
  def available_templates(affiliate)
    templates = affiliate.available_templates
    templates.blank? ? [Template.default] : templates
  end

  # deprecated - Search Consumer
  def unavailable_templates(affiliate)
    Template.all - available_templates(affiliate)
  end
end
