module ApplicationHelper
  NON_CAPITALIZED = %w{a al an and ante as at bajo but by cabe con conmigo consigo contigo contra de del desde
      durante e el en entre et etc for from hacia hasta in into la las los mediante ni nor o of off on onto or out
      para pero por salvo según sin so sobre than the to tras u un una unas unos v versus via vs vía with y}

  def display_for(role)
    yield if (current_user && current_user.send("is_#{role}?"))
  end

  def sentence_case(str)
    str.gsub(/\b[a-z]+/) { |w| NON_CAPITALIZED.include?(w) ? w : w.capitalize }.sub(/^[a-z]/) { |l| l.upcase }.sub(/\b[a-z][^\s]*?$/) { |l| l.capitalize }
  end

  def build_page_title(page_title)
    (page_title.blank? ? "" : "#{page_title} - ") + (t :site_title)
  end

  def show_flash_messages
    unless (flash.nil? or flash.empty?)
      html = content_tag(:div, flash.collect { |key, msg| content_tag(:div, msg, :class => key) }, :id => 'flash-message', :class => 'flash-message')
      html << content_tag(:script, "setTimeout(\"new Effect.Fade('flash-message');\",15000)", :type => 'text/javascript')
      html
    end
  end

  def url_for_mobile_mode(new_mobile_mode)
    new_params = request.params.update({:m => new_mobile_mode.to_s})
    url_for({:controller => params[:controller], :action => params[:action], :params => new_params})
  end

  def link_to_mobile_mode(text, new_mobile_mode)
    link_to(text, url_for_mobile_mode(new_mobile_mode))
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
      ["Home", "http://www.usa.gov/index.shtml"],
      ["About Us", "http://www.usa.gov/About.shtml"],
      ["Contact Us", "http://www.usa.gov/Contact_Us.shtml"],
      ["Contact Government", "http://www.usa.gov/Contact/Elected.shtml"],
      ["FAQs", "http://www.usa.gov/Contact/Faq.shtml"],
      ["Website Policies", "http://www.usa.gov/About/Important_Notices.shtml"],
      ["Privacy", "http://www.usa.gov/About/Privacy_Security.shtml"],
      ["Suggest-A-Link", "http://www.usa.gov/feedback/SuggestLinkForm.jsp"],
      ["Link to Us", "http://www.usa.gov/About/Usagov_Logos.shtml"],
      ["Accessibility", "/pages/accessibility"],
      ["API", "/api"]
    ],
    :es => [
      ["GobiernoUSA.gov", "http://GobiernoUSA.gov"],
      ["Privacidad", "http://www.usa.gov/gobiernousa/Privacidad_Seguridad.shtml"],
      ["Enlace su sitio al nuestro", "http://www.usa.gov/gobiernousa/link_to_us.shtml"],
      ["Sugiera un enlace", "http://www.usa.gov/feedback/sugieraunenlaceformulario.jsp"]
    ]
  }

  BACKGROUND_COLORS = {:en => "#003366", :es => "#A40000"}

  def header_links
    iterate_links(HEADER_LINKS[I18n.locale.to_sym])
  end

  def footer_links
    iterate_links(FOOTER_LINKS[I18n.locale.to_sym].clone << [t(:mobile), I18n.locale.to_s == 'es' ? search_path(:query => '', :locale => 'es', :m => 'true') :url_for_mobile_mode("true")])
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
      elements << link_to("Logout", url_for_logout, :method => :delete)
    else
      elements << link_to("Login", url_for_login)
    end
    elements << link_to("Help Desk", "http://searchsupport.usa.gov/home", :target => "_blank")
    elements.join(" | ")
  end

  def analytics_header_navigation_for(cur_user)
    elements = []
    if cur_user
      elements << cur_user.email
      elements << link_to("My Account", account_path)
      elements << link_to("Query Groups Admin", analytics_query_groups_path) if cur_user.is_analyst_admin?
      elements << link_to("Logout", url_for_logout, :method => :delete)
    end
    elements << link_to("Help Desk", "http://searchsupport.usa.gov/home", :target => "_blank")
    elements.join(" | ")
  end

  def other_locale_str
    I18n.locale.to_s == "en" ? "es" : "en"
  end

  def english_locale?
    I18n.locale.to_s == "en"
  end

  def locale_dependent_background_color
    BACKGROUND_COLORS[I18n.locale.to_sym] || BACKGROUND_COLORS[:en]
  end

  def highlight_hit(hit, sym)
    return hit.highlights(sym).first.format { |phrase| "<strong>#{h phrase}</strong>" } unless hit.highlights(sym).first.nil?
    hit.instance.send(sym)
  end

  def mobile_menu_item(link_text, target, is_footer = false)
    arrow = content_tag(:div, '>', :class=> "navFloatRight")
    link = link_to link_text, target, :class => "mobileNavLink"
    content_tag(:div, arrow + link, :class=> is_footer ? "navFooter" : "navBodyItem")
  end

  def url_for_login
    url_for(:controller => "/user_sessions",
            :action => "new",
            :protocol => ssl_protocol,
            :only_path => false)
  end

  def url_for_logout
    url_for(:controller => "/user_sessions",
            :action => "destroy",
            :protocol => ssl_protocol,
            :only_path => false)
  end

  def favicon_link_tag
    tag('link', {
        :rel  => 'shortcut icon',
        :type => 'image/vnd.microsoft.icon',
        :href => path_to_image("/favicon.ico")
    })
  end

  def truncate_on_words(text, length)
    return text if text.length <= length
    truncated = text[0..length]
    last_space_index = (truncated.reverse.index(/\W/) || 0)
    last_word_character_index = truncated.length - (truncated.reverse.index(/\w/, last_space_index) || 0)
    truncated = truncated[0...last_word_character_index] unless last_space_index.nil?
    "#{truncated}..."
  end

  private

  def ssl_protocol
    SSL_PROTOCOL
  end

  def iterate_links(links)
    links.collect { |link| link_to(link[0], link[1]) }.join(' | ') unless links.nil?
  end
end
