# coding: utf-8
module ApplicationHelper

  def current_user_is?(role)
    current_user && current_user.send("is_#{role}?")
  end

  def build_page_title(page_title)
    if image_search?
      site_title = (t :images_site_title)
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
    url_for({:controller => controller.controller_path, :action => controller.action_name}.reverse_merge(new_params))
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
      ["Publications", "http://publications.usa.gov/"]],
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
      ["Privacy", "http://www.usa.gov/About/Privacy_Security.shtml"]],
    :es => [
      ["GobiernoUSA.gov", "http://www.usa.gov/gobiernousa/index.shtml", "first"],
      ["Políticas del sitio", "http://www.usa.gov/gobiernousa/Politicas_Sitio.shtml"],
      ["Privacidad", "http://www.usa.gov/gobiernousa/Privacidad_Seguridad.shtml"]
    ]
  }

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
    links << link_to('Home', BLOG_URL, :class => 'first')
    links << link_to('How It Works', "#{BLOG_URL}/help-desk.html")
    links << link_to('Our Customers', "#{BLOG_URL}/customers.html")
    links << link_to('Sign Up', login_path, :class => 'last')
    raw links
  end

  def basic_header_navigation_for(cur_user)
    links = []
    if cur_user
      links << content_tag(:li, "#{cur_user.email}", :class => 'first')
      links << content_tag(:li, link_to("My Account", account_path))
      links << content_tag(:li, link_to("Sign Out", url_for_logout, :method => :delete))
    else
      links << content_tag(:li, link_to("Sign In", url_for_login), :class => 'first')
    end
    raw content_tag(:ul, raw(links.join("\n")))
  end

  def render_user_navigation(current_user)
    links = []
    if current_user
      links << link_to('Super Admin', admin_home_page_path) if current_user_is?(:affiliate_admin)
      links << link_to('Admin Center', home_affiliates_path) if current_user_is?(:affiliate)
      first_added = false
      list_items = links.collect do |link|
        unless first_added
          first_added = true
          content_tag(:li, link.html_safe, :class => 'first')
        else
          content_tag(:li, link.html_safe)
        end
      end
      content_tag(:ul, list_items.join("\n").html_safe).html_safe
    end
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

  def highlight_hit(hit, field_name)
    sym = field_name.to_sym
    if (hit.instance.is_a?(BoostedContent) or hit.instance.is_a?(IndexedDocument)) and hit.instance.affiliate.locale == 'es'
      sym = "#{field_name}_text".to_sym
    end
    return hit.highlight(sym).format { |phrase| "<strong>#{phrase}</strong>" } unless hit.highlight(sym).nil?
    h hit.instance.send(field_name)
  end

  def url_for_login
    url_for(:controller => "/user_sessions",
            :action => "new",
            :protocol => ssl_protocol,
            :only_path => false)
  end

  def url_for_logout
    url_for(:controller => '/user_sessions', :action => :destroy)
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
      highlight.instance_variable_get(:@highlight).scan(Sunspot::Search::Highlight::HIGHLIGHT_MATCHER).flatten.each do |term|
        unless done.include?(term)
          raw_text.gsub!(/\b(#{term})\b/, '<strong>\1</strong>')
          done[term] = true
        end
      end
    end
    raw raw_text
  end

  def breadcrumbs(breadcrumbs)
    trail = link_to('USASearch', BLOG_URL)
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
    end
    raw content
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

  def connect_links
    tags = []
    tags << link_to('Twitter', "http://twitter.com/usasearch", :class => 'twitter', :title => 'Twitter')
    tags << link_to('Mobile', "http://m.usa.gov", :class => 'mobile', :title => 'Mobile') if display_mobile_or_add_this_link?
    tags << link_to('Our Blog', BLOG_URL, :class => 'blog', :title => 'Our Blog')
    tags << link_to('Share', "http://www.addthis.com/bookmark.php", :class => 'share last', :title => 'Share') if display_mobile_or_add_this_link?
    tags.join("\n").html_safe
  end

  def render_date(date, locale = I18n.locale)
    unless date.nil?
      locale.to_sym == :es ? date.strftime("%-d/%-m/%Y") : date.strftime("%-m/%-d/%Y")
    end
  end

  def attribution
    txt = []
    txt << "<!-- ----------------------------------------------------------------------------------------------- -->"
    txt << "<!--                                  Results by USASearch.                                          -->"
    txt << "<!-- helping government create a great search experience. Learn more at http://usasearch.howto.gov   -->"
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

  def display_mobile_or_add_this_link?
    return true if %w{ home images searches image_searches pages }.include?(controller.controller_path)
    controller.controller_path == 'affiliates/home' and %w{ index demo how_it_works }.include?(controller.action_name)
  end

  def append_html_prose(buffer, node, max_chars, max_paragraphs)
    return [max_chars, max_paragraphs] if max_chars <= 0

    case node.node_type

      # todo: should have separate case for entity refs but they will probably not work anyways until ruby 1.9

      # we prefer to chop at word boundaries

      when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::ENTITY_REF_NODE
        mb_chars = node.text? ? CGI::escapeHTML(node.text) : node.text

        if mb_chars.length <= max_chars
          buffer << mb_chars
          max_chars -= mb_chars.length
        else
          last_space_index = (mb_chars.rindex(/\s/, max_chars) || 0) rescue 0
          truncated_text = mb_chars[0..last_space_index].gsub(/\s+/, ' ') unless last_space_index.nil?
          buffer << "#{truncated_text}..."
          max_chars = 0
        end

      # even if not all children are inserted, the parent tags need to be properly closed

      when Nokogiri::XML::Node::ELEMENT_NODE, Nokogiri::XML::Node::DOCUMENT_FRAG_NODE
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
