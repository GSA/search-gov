# coding: utf-8
module ApplicationHelper

  def current_user_is?(role)
    current_user && current_user.send("is_#{role}?")
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

  def english_locale?
    I18n.locale.to_s == "en"
  end

  def url_for_logout
    url_for(:controller => '/user_sessions', :action => :destroy)
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

  def render_date(datetime, locale = I18n.locale)
    l(datetime.to_date, locale: locale, format: :slashes) unless datetime.nil?
  end

  def attribution
    txt = []
    txt << '<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->'
    txt << '<!--                                  Powered by Search.gov                                          -->'
    txt << '<!-- helping government create a great search experience. Learn more at https://search.digitalgov.gov -->'
    txt << txt.first
    txt.join("\n").html_safe
  end

  def time_ago_in_words(from_time, include_seconds = false, options = {})
    options.reverse_merge!(:scope => :'datetime.time_ago_in_words')
    distance_of_time_in_words(from_time, Time.current, include_seconds, options)
  end

end
