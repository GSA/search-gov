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

  def basic_header_navigation_for(cur_user)
    links = []
    links << content_tag(:li, "#{cur_user.email}", :class => 'first')
    links << content_tag(:li, link_to("My Account", account_path))
    links << content_tag(:li, link_to("Sign Out", url_for_logout, :method => :delete))
    raw content_tag(:ul, raw(links.join("\n")))
  end

  def render_user_navigation(current_user)
    links = []
    if current_user
      links << link_to('Super Admin', admin_home_page_path) if current_user_is?(:affiliate_admin)
      links << link_to('Admin Center', sites_path) if current_user_is?(:affiliate)
      first_added = false
      list_items = links.collect do |link|
        if first_added
          content_tag(:li, link.html_safe)
        else
          first_added = true
          content_tag(:li, link.html_safe, class: 'first')
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
    return hit.highlight(sym).format { |phrase| "<strong>#{phrase}</strong>" } unless hit.highlight(sym).nil?
    h hit.instance.send(field_name)
  end

  def url_for_logout
    url_for(:controller => '/user_sessions', :action => :destroy)
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
    trail = ''
    breadcrumbs.each { |breadcrumb| trail << breadcrumb }
    content_tag(:div, trail.html_safe, :class => 'breadcrumbs')
  end

  def render_robots_meta_tag
    content = ''
    if (request.path =~ /^\/(image_searches|search(?!usagov)|usa\/)/i)
      content = tag(:meta, {:name => 'ROBOTS', :content => 'NOINDEX, NOFOLLOW'})
    end
    raw content
  end

  def render_date(date, locale = I18n.locale)
    unless date.nil?
      locale.to_sym == :es ? date.strftime("%-d/%-m/%Y") : date.strftime("%-m/%-d/%Y")
    end
  end

  def attribution
    txt = []
    txt << '<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->'
    txt << '<!--                                  Powered by DigitalGov Search                                   -->'
    txt << '<!-- helping government create a great search experience. Learn more at http://search.digitalgov.gov -->'
    txt << txt.first
    txt.join("\n").html_safe
  end
end
