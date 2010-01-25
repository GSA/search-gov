module ApplicationHelper
  def show_flash_messages
    unless (flash.nil? or flash.empty?)
      html = content_tag(:div, flash.collect{ |key, msg| content_tag(:div, msg, :class => key) }, :id => 'flash-message', :class => 'flash-message')
      html << content_tag(:script, "setTimeout(\"new Effect.Fade('flash-message');\",5000)", :type => 'text/javascript')
      html
    end
  end

  HEADER_LINKS = {
    :en => [
      ["USA.gov", "http://usa.gov"],
      ["GobiernoUSA.gov", "http://GobiernoUSA.gov"],
      ["Email USA.gov", "http://www.usa.gov/questions"]
    ],
    :es => [
      ["GobiernoUSA.gov", "http://GobiernoUSA.gov"],
      ["USA.gov (en inglés)", "http://usa.gov"],
      ["Contáctenos", "http://www.usa.gov/gobiernousa/Contactenos.shtml"]
    ]
  }

  FOOTER_LINKS = {
    :en => [
      ["Home", "http://www.usa.gov/index.shtml" ],
      ["About Us", "http://www.usa.gov/About.shtml" ],
      ["Contact Us", "http://www.usa.gov/Contact_Us.shtml" ],
      ["Contact Government", "http://www.usa.gov/Contact/Elected.shtml" ],
      ["FAQs", "http://www.usa.gov/Contact/Faq.shtml" ],
      ["Website Policies", "http://www.usa.gov/About/Important_Notices.shtml" ],
      ["Privacy", "http://www.usa.gov/About/Privacy_Security.shtml" ],
      ["Suggest-A-Link", "http://www.usa.gov/feedback/SuggestLinkForm.jsp" ],
      ["Link to Us", "http://www.usa.gov/About/FirstGov_Logos.shtml"]
    ],
    :es => [
      ["GobiernoUSA.gov", "http://GobiernoUSA.gov"],
      ["Privacidad", "http://www.usa.gov/gobiernousa/Privacidad_Seguridad.shtml"],
      ["Enlace su sitio al nuestro", "http://www.usa.gov/gobiernousa/link_to_us.shtml"],
      ["Sugiera un enlace", "http://www.usa.gov/feedback/sugieraunenlaceformulario.jsp"]
    ]
  }

  BACKGROUND_COLORS = { :en => "#003366", :es => "#A40000" }

  def header_links
    iterate_links(HEADER_LINKS[I18n.locale.to_sym])
  end

  def footer_links
    iterate_links(FOOTER_LINKS[I18n.locale.to_sym])
  end
  
  def render_webtrends_code
    if params[:locale] == 'es'
      render :partial => 'shared/webtrends_spanish'
    else
      render :partial => 'shared/webtrends_english'
    end
  end
  
  def basic_header_navigation_for(cur_user)
    elements = []
    if cur_user
      elements << cur_user.email
      elements << link_to("My Account", account_path)
      elements << link_to("Logout", user_session_path, :method => :delete)
      elements << link_to("FAQ", affiliates_path) if cur_user.is_affiliate?
      elements << link_to("Users", admin_users_path) if cur_user.is_affiliate_admin?
    end
    elements << link_to("USAsearch.gov", home_page_path)
    elements.join(" | ")
  end

  def analytics_header_navigation_for(cur_user)
    elements = []
    if cur_user
      elements << cur_user.email
      elements << link_to("My Account", account_path)
      elements << link_to("Logout", user_session_path, :method => :delete)
      elements << link_to("FAQ", analytics_faq_path)
      elements << link_to("Query Groups Admin", analytics_query_groups_path) if cur_user.is_affiliate_admin?
    end
    elements << link_to("USAsearch.gov", home_page_path)
    elements.join(" | ")
  end

  def other_locale_str
    I18n.locale.to_s == "en" ? "es" : "en"
  end

  def locale_dependent_background_color
    BACKGROUND_COLORS[I18n.locale.to_sym] || BACKGROUND_COLORS[:en]
  end

  def its_beta
    content_tag(:span, link_to("BETA", affiliates_path), :class => "beta")
  end

  def highlight_hit(hit, sym)
    return hit.highlights(sym).first.format { |phrase| "<strong>#{phrase}</strong>" } unless hit.highlights(sym).first.nil?  
    hit.instance.send(sym)
  end

  private

  def iterate_links(links)
    links.collect {|link| link_to(link[0], link[1]) }.join(' | ') unless links.nil?
  end
end
