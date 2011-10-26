module ApplicationHelper

  def current_user_is?(role)
    current_user && current_user.send("is_#{role}?")
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
      html = ""
      flash_msgs = content_tag(:div, :class => 'flash-message', :id => 'flash_message') do
        messages = flash.collect do |key, msg|
          content_tag(:div, msg, :class => key).html_safe
        end
        messages.join(" ").html_safe
      end
      html << flash_msgs
      html << content_tag(:script, "setTimeout(\"new Effect.Fade('flash-message');\",15000)".html_safe, :type => 'text/javascript').html_safe
      html.html_safe
    else
      ""
    end
  end

  def url_for_mobile_mode(new_mobile_mode)
    new_params = request.params.update({:format => nil, :m => new_mobile_mode.to_s})
    url_for({ :controller => controller.controller_path, :action => controller.action_name }.reverse_merge(new_params))
  end

  def link_to_mobile_mode(text, new_mobile_mode)
    link_to(text, url_for_mobile_mode(new_mobile_mode))
  end

  HEADER_LINKS = {
    :en => [
      ["USA.gov", "http://www.usa.gov/index.shtml", "first"],
      ["FAQs", "http://answers.usa.gov/"],
      ["E-mail USA.gov", "http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/ask.php"],
      ["Chat", "http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/chat.php"],
      ["Publications", "http://publications.usa.gov/"] ],
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
    raw iterate_links(HEADER_LINKS[I18n.locale.to_sym])
  end

  def footer_links
    links = FOOTER_LINKS[I18n.locale.to_sym].clone
    (links << [I18n.translate(:mobile), "http://m.gobiernousa.gov"]) if spanish_locale?
    raw iterate_links(links)
  end

  def render_about_usasearch
    if english_locale?
      result = content_tag(:div, :class => 'footer about') do
        content = content_tag(:span, "ABOUT USASearch   > ")
        content << about_usasearch_links
        content
      end
      result
    end
  end

  def about_usasearch_links
    links = ''
    links << link_to("USASearch Program", program_path, :class => 'first')
    links << link_to("Affiliate Program", affiliates_path)
    links << link_to("APIs and Web Services", api_docs_path)
    links << link_to("Search.USA.gov", searchusagov_path, :class => 'last')
    raw links
  end

  def render_webtrends_code
    if I18n.locale.to_s == 'es'
      render :partial => 'shared/webtrends_spanish'
    else
      render :partial => 'shared/webtrends_english'
    end
  end

  def render_mobile_webtrends_code
    if I18n.locale.to_s == 'es'
      render :partial => 'shared/webtrends_mobile_spanish'
    else
      render :partial => 'shared/webtrends_mobile_english'
    end
  end

  def basic_header_navigation_for(cur_user)
    elements = []
    if cur_user
      elements << "#{cur_user.email}"
      elements << link_to("My Account", account_path)
      elements << link_to("Sign Out", url_for_logout, :method => :delete)
    else
      elements << link_to("Sign In", url_for_login)
    end

    results = elements.collect do |element|
      content_tag(:li, raw(element))
    end
    results << content_tag(:li, mail_to("***REMOVED***", "Help Desk", :subject => "USASearch HelpDesk Request"), :class => 'last')
    raw content_tag(:ul, raw(results.join))
  end

  def other_locale_str
    I18n.locale.to_s == "en" ? "es" : "en"
  end

  def english_locale?
    I18n.locale.to_s == "en"
  end

  def spanish_locale?
    I18n.locale.to_s == "es"
  end

  def locale_dependent_background_color
    BACKGROUND_COLORS[I18n.locale.to_sym] || BACKGROUND_COLORS[:en]
  end

  def highlight_hit(hit, sym)
    return hit.highlights(sym).first.format { |phrase| "<strong>#{phrase}</strong>" } unless hit.highlights(sym).first.nil?
    hit.instance.send(sym)
  end

  def mobile_menu_item(link_text, target)
    content_tag(:li, link_to(content_tag(:div, link_text), target), :class => 'list-item')
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

  def truncate_html_prose_on_words(html, length, max_paragraphs = nil)
    html_root = Nokogiri::HTML.fragment(html.strip) rescue nil
    truncated_html = ""
    append_html_prose(truncated_html, html_root, length, max_paragraphs) unless html_root.nil?
    truncated_html
  end


  def highlight_like_solr(text, highlights)
    raw_text = text.to_str
    done = {}
    highlights.each do |highlight|
      highlight.instance_variable_get(:@highlight).scan(Sunspot::Search::Highlight::HIGHLIGHT_MATCHER).each do |term|
        unless done.include?(term)
          raw_text.gsub!(/\b(#{term})\b/, '<strong>\1</strong>')
          done[term] = true
        end
      end
    end
    raw raw_text
  end

  def render_trending_searches
    render :partial => 'shared/trending_searches' if (params[:locale].blank? || params[:locale] == 'en')
  end

  def breadcrumbs(breadcrumbs)
    trail = link_to('USASearch', program_path)
    breadcrumbs.each { |breadcrumb| trail << breadcrumb }
    content_tag(:div, trail, :class => 'breadcrumbs')
  end

  def url_for_mobile_home_page(locale = I18n.locale)
    locale.to_sym == :es ? 'http://m.gobiernousa.gov' : root_path(:locale => locale, :m => true)
  end

  def render_robots_meta_tag
    content = ''
    if (request.path =~ /^\/(image_searches|search(?!usagov)|usa\/)/i) or error_page?
      content = tag(:meta, {:name => 'ROBOTS', :content => 'NOINDEX, NOFOLLOW'})
    elsif mobile_landing_page?
      content = tag(:meta, {:name => 'ROBOTS', :content => 'INDEX, NOFOLLOW'})
    end
    raw content
  end

  def mobile_landing_page?
    controller.controller_path == "home" and request.format == :mobile
  end

  def render_connect_section
    return unless english_locale?
    content_tag(:div, :class => 'connect') do
      tags = []
      tags << content_tag(:span, "Connect with USASearch")
      tags << connect_links
      tags.join("\n").html_safe
    end
  end

  def render_connect_links
    connect_links if display_connect_links?
  end

  def connect_links
    tags = []
    tags << link_to('Twitter', "http://twitter.com/usasearch", :class => 'twitter', :title => 'Twitter')
    tags << link_to('Mobile', "http://m.usa.gov", :class => 'mobile', :title => 'Mobile')
    tags << link_to('Our Blog', "http://searchblog.usa.gov", :class => 'blog', :title => 'Our Blog')
    tags << link_to('Share', "http://www.addthis.com/bookmark.php", :class => 'share last', :title => 'Share')
    tags.join("\n").html_safe
  end

  def render_date(date)
    date.strftime("%m/%d/%Y") unless date.nil?
  end

  def attribution
    txt = []
    txt << "<!-- ----------------------------------------------------------------------------------- -->"
    txt << "<!--                                  Powered by USASearch.                              -->"
    txt << "<!-- Register for the USASearch Affiliate Program at http://search.usa.gov/affiliates/   -->"
    txt << txt.first
    txt.join("\n").html_safe
  end

  private

  def ssl_protocol
    SSL_PROTOCOL
  end

  def iterate_links(links)
    links.collect { |link| link_to(link[0], link[1], :class => link[2]) }.join unless links.nil?
  end

  def display_connect_links?
    return true if %w{ home images recalls forms searches image_searches pages }.include?(controller.controller_path)
    controller.controller_path == 'affiliates/home' and %w{ index demo how_it_works }.include?(controller.action_name)
  end

  def append_html_prose(buffer, node, max_chars, max_paragraphs)
    return [max_chars, max_paragraphs] if max_chars <= 0

    case node.node_type

  # todo: should have separate case for entity refs but they will probably not work anyways until ruby 1.9

  # we prefer to chop at word boundaries

    when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::ENTITY_REF_NODE :
      mb_chars = node.text.mb_chars

      if mb_chars.length <= max_chars
        buffer << mb_chars
        max_chars -= mb_chars.length
      else
        last_space_index = (mb_chars.rindex(/\W/, max_chars) || 0) rescue 0
        truncated_text = mb_chars[0..(mb_chars.rindex(/\w/, last_space_index) || 0)] unless last_space_index.nil?
        buffer << "#{truncated_text}..."
        max_chars = 0
      end

  # even if not all children are inserted, the parent tags need to be properly closed

    when Nokogiri::XML::Node::ELEMENT_NODE, Nokogiri::XML::Node::DOCUMENT_FRAG_NODE :
      if (max_paragraphs.present? && max_paragraphs == 0)
        max_paragraphs -= 1
        buffer << "..."
      elsif max_paragraphs.nil? || max_paragraphs > 0
        if node.element?
          buffer << "<#{node.name}"
          node.attributes.each do |name, value|
            buffer << " #{name}='#{value}'"
          end
          buffer << ">"

        end
        node.children.each do |child|
          max_chars, max_paragraphs = append_html_prose(buffer, child, max_chars, max_paragraphs)
        end

        if node.element?
          buffer << "</#{node.name}>"
          if max_paragraphs.present? && %w{h1 h2 h3 p li div quote}.include?(node.name)
            max_paragraphs -= 1
          end
        end
      end
    else
    end
    [max_chars, max_paragraphs]
  end

end
