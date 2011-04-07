module ApplicationHelper
  def display_for(role)
    yield if (current_user && current_user.send("is_#{role}?"))
  end

  def build_page_title(page_title)
    if forms_search?
      site_title = (t :forms_site_title)
    elsif image_search?
      site_title = (t :images_site_title)
    elsif recalls_search?
      site_title = (t :recalls_site_title)
    else
      site_title = page_title.blank? ? (t :site_title) : (t :serp_title)
    end
    (page_title.blank? ? "" : "#{page_title} - ") + site_title
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
      ["USA.gov", "http://www.usa.gov/index.shtml", "first"],
      ["FAQs", "http://answers.usa.gov/"],
      ["Email USA.gov", "http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/ask.php"],
      ["Chat", "http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/chat.php"] ],
    :es => [
      ["GobiernoUSA.gov", "http://www.usa.gov/gobiernousa/index.shtml", "first"],
      ["Respuestas", "http://respuestas.gobiernousa.gov/"],
      ["Contactos", "http://www.usa.gov/gobiernousa/Contactenos.shtml"]
    ]
  }

  FOOTER_LINKS = {
    :en => [
      ["USA.gov", "http://www.usa.gov/index.shtml", "first"],
      ["Website Policies", "http://www.usa.gov/About/Important_Notices.shtml"],
      ["Privacy", "http://www.usa.gov/About/Privacy_Security.shtml"] ],
    :es => [
      ["GobiernoUSA.gov", "http://www.usa.gov/gobiernousa/index.shtml", "first"],
      ["Políticas del sitio", "http://www.usa.gov/gobiernousa/Politicas_Sitio.shtml"],
      ["Privacidad", "http://www.usa.gov/gobiernousa/Privacidad_Seguridad.shtml"]
    ]
  }

  BACKGROUND_COLORS = {:en => "#003366", :es => "#A40000"}

  def header_links
    iterate_links(HEADER_LINKS[I18n.locale.to_sym])
  end

  def footer_links
    iterate_links(FOOTER_LINKS[I18n.locale.to_sym].clone << [t(:mobile), url_for_mobile_home_page])
  end

  def render_about_usasearch
    if english_locale?
      content_tag(:div, :class => 'footer about') do
        content = content_tag(:span, "ABOUT USASearch &nbsp; &gt;")
        content << about_usasearch_links
        content
      end
    end
  end

  def about_usasearch_links
    links = ''
    links << link_to("USASearch Program", program_path, :class => 'first')
    links << link_to("Affiliate Program", affiliates_path)
    links << link_to("APIs and Web Services", api_docs_path)
    links << link_to("Search.USA.gov", searchusagov_path)
    links
  end

  def render_webtrends_code
    if params[:locale] == 'es'
      render :partial => 'shared/webtrends_spanish'
    else
      render :partial => 'shared/webtrends_english'
    end
  end

  def render_mobile_webtrends_code
    if params[:locale] == 'es'
      render :partial => 'shared/webtrends_mobile_spanish'
    else
      render :partial => 'shared/webtrends_mobile_english'
    end
  end

  def basic_header_navigation_for(cur_user)
    elements = []
    if cur_user
      elements << "#{cur_user.email} |"
      elements << link_to("My Account |", account_path)
      elements << link_to("Sign Out |", url_for_logout, :method => :delete)
    else
      elements << link_to("Sign In |", url_for_login)
    end
    elements << link_to("Help Desk", "http://searchsupport.usa.gov/home", :target => "_blank")

    results = elements.collect do |element|
      content_tag(:li, element)
    end
    content_tag(:ul, results.join)
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
    mb_chars = text.mb_chars
    return text if mb_chars.length <= length
    truncated = mb_chars[0..length]
    last_space_index = (truncated.reverse.index(/\W/) || 0)
    last_word_character_index = truncated.length - (truncated.reverse.index(/\w/, last_space_index) || 0)
    truncated = truncated[0...last_word_character_index] unless last_space_index.nil?
    "#{truncated}..."
  end

  def highlight_like_solr(text, highlights)
    highlights.each do |highlight|
      highlight.instance_variable_get(:@highlight).scan(Sunspot::Search::Highlight::HIGHLIGHT_MATCHER).each do |term|
        text.gsub!(/\b(#{term})\b/, '<strong>\1</strong>')
      end
    end
    text
  end

  def render_trending_searches
    render(:partial => 'shared/trending_searches') if params[:locale].blank? || params[:locale] == 'en'
  end

  def breadcrumbs(breadcrumbs)
    trail = link_to('USASearch', program_path)
    breadcrumbs.each { |breadcrumb| trail << breadcrumb }
    content_tag(:div,trail, :class => 'breadcrumbs')
  end

  def url_for_mobile_home_page(locale = I18n.locale)
    locale.to_sym == :es ? 'http://m.gobiernousa.gov' : root_path(:locale => locale, :m => true)
  end

  private

  def ssl_protocol
    SSL_PROTOCOL
  end

  def iterate_links(links)
    links.collect { |link| link_to(link[0], link[1], :class => link[2]) }.join unless links.nil?
  end
end
