module SearchHelper

  SPECIAL_URL_PATH_EXT_NAMES = %w{doc pdf ppt ps rtf swf txt xls}

  def result_partial_for(search)
    if search.is_a?(ImageSearch)
      "/image_searches/result"
    else
      "/searches/result"
    end
  end

  def display_image_result_links(result, search, affiliate, index)
    affiliate_name = affiliate.name rescue ""
    query = search.spelling_suggestion ? search.spelling_suggestion : search.query
    onmousedown_attribute = onmousedown_attribute_for_image_click(query, result["MediaUrl"], index, affiliate_name, "IMAG", search.queried_at_seconds)
    html = tracked_click_thumbnail_image_link(result, onmousedown_attribute)
    raw html << tracked_click_thumbnail_link(result, onmousedown_attribute)
  end

  def display_thumbnail_image_link(result, search, index, max_width = nil, max_height = nil)
    onmousedown_attribute = onmousedown_attribute_for_image_click(search.query, result["MediaUrl"], index, nil, "IMAG", search.queried_at_seconds)
    tracked_click_thumbnail_image_link(result, onmousedown_attribute, max_width, max_height)
  end

  def tracked_click_thumbnail_image_link(result, onmousedown_attr, max_width = nil, max_height = nil)
    raw link_to thumbnail_image_tag(result, max_width, max_height),
            result["Url"],
            :onmousedown => onmousedown_attr,
            :alt => result["title"],
            :rel => "no-follow"
  end

  def tracked_click_thumbnail_link(result, onmousedown_attr)
    link = URI.parse(result["Url"]).host rescue shorten_url(result["Url"])
    link_to link,
            result["MediaUrl"],
            :onmousedown => onmousedown_attr,
            :rel => "no-follow"
  end

  def thumbnail_image_tag(result, max_width=nil, max_height=nil)
    width = result["Thumbnail"]["Width"].to_f
    height = result["Thumbnail"]["Height"].to_f
    reductions = [
      (max_width && width > max_width) ? (max_width.to_f / width) : 1,
      (max_height && height > max_height) ? (max_height.to_f / height) : 1
    ]
    reduction = reductions.min

    raw image_tag result["Thumbnail"]["Url"],
              :width  => (width * reduction).to_i,
              :height => (height * reduction).to_i,
              :title  => result["title"]
  end

  def display_result_links (result, search, affiliate, position, show_cache_link = true)
    html = tracked_click_link(h(result['unescapedUrl']), h(shorten_url(result['unescapedUrl'])), search, affiliate, position, 'BWEB')
    unless result['cacheUrl'].blank? or !show_cache_link
      html << " - "
      html << link_to((t :cached), "#{result['cacheUrl']}", :class => 'cache_link')
    end
    raw html
  end

  def display_deep_links_for(result)
    return if result["deepLinks"].nil?
    rows = []
    result["deepLinks"].in_groups_of(2)[0, 4].each do |row_pair|
      row = content_tag(:td, row_pair[0].nil? ? "" : link_to((h row_pair[0].title), row_pair[0].url))
      row << content_tag(:td, row_pair[1].nil? ? "" : link_to((h row_pair[1].title), row_pair[1].url))
      rows << content_tag(:tr, row)
    end
    content_tag(:table, raw(rows), :class=>"deep_links")
  end

  def display_result_extname_prefix(result)
    begin
      path_extname = File.extname(URI.parse(result['unescapedUrl']).path)[1..-1]
      if SPECIAL_URL_PATH_EXT_NAMES.include?( path_extname.downcase )
        raw "<span class=\"uext_type\">[#{path_extname.upcase}]</span> "
      else
        ""
      end
    rescue
      ""
    end
  end

  def display_result_title (result, search, affiliate, position)
    raw tracked_click_link(h(result['unescapedUrl']), translate_bing_highlights(h(result['title'])), search, affiliate, position, 'BWEB')
  end

  def tracked_click_link(url, title, search, affiliate, position, source, opts = nil)
    aff_name = affiliate.name rescue ""
    query = search.spelling_suggestion ? search.spelling_suggestion : search.query
    query = query.gsub("'", "\\\\'")
    onmousedown = onmousedown_for_click(query, position, aff_name, source, search.queried_at_seconds)
    raw "<a href=\"#{url}\" #{onmousedown} #{opts}>#{title}</a>"
  end

  def render_spotlight_with_click_tracking(spotlight_html, query, queried_at_seconds)
    require 'hpricot'
    doc = Hpricot(spotlight_html)
    (doc/:a).each_with_index do |e, idx|
      url =  e.attributes['href']
      tag = e.inner_html
      onmousedown = onmousedown_for_click(query, idx, '', 'SPOT', queried_at_seconds)
      e.swap("<a href=\"#{url}\" #{onmousedown}>#{tag}</a>")
    end
    raw doc.to_html
  end

  def onmousedown_for_click(query, zero_based_index, affiliate_name, source, queried_at)
    "onmousedown=\"return clk('#{h query}',this.href, #{zero_based_index + 1}, '#{affiliate_name}', '#{source}', #{queried_at})\""
  end

  def onmousedown_attribute_for_image_click(query, media_url, zero_based_index, affiliate_name, source, queried_at)
    "return clk('#{h(escape_javascript(query))}', '#{media_url}', #{zero_based_index + 1}, '#{affiliate_name}', '#{source}', #{queried_at})"
  end

  def display_result_description (result)
    translate_bing_highlights(h(result['content']))
  end

  def translate_bing_highlights(body)
    body.gsub(/\xEE\x80\x80/, '<strong>').gsub(/\xEE\x80\x81/, '</strong>')
  end

  def strip_bing_highlights(body)
    body.gsub(/\xEE\x80\x80/, '').gsub(/\xEE\x80\x81/, '')
  end

  def shunt_from_bing_to_usasearch(bingurl, affiliate)
    query = CGI::unescape(bingurl.split("?q=").last)
    opts = {:query=> query}
    opts.merge!(:affiliate => affiliate.name) if affiliate
    search_path(opts)
  end

  def spelling_suggestion(search, affiliate)
    if (search.spelling_suggestion)
      rendered_suggestion = translate_bing_highlights(search.spelling_suggestion)
      suggestion_for_url = strip_bing_highlights(search.spelling_suggestion)
      opts = {:query=> suggestion_for_url}
      opts.merge!(:affiliate => affiliate.name) if affiliate
      corrected_url = image_search? ? image_search_path(opts) : search_path(opts)
      opts.merge!(:query => "+#{search.query}")
      original_url = image_search? ? image_search_path(opts) : search_path(opts)
      did_you_mean = t :did_you_mean,
                       :assumed_term => tracked_click_link(corrected_url, h(rendered_suggestion), search, affiliate, 0, 'BSPEL', "style='font-weight:bold'"),
                       :term_as_typed => tracked_click_link(original_url, h(search.query), search, affiliate, 0, 'OVER', "style='font-style:italic'")
      content_tag(:h4, raw(did_you_mean))
    end
  end

  def results_summary(a, b, total, q, show_logo = true)
    summary = t :results_summary, :from => a, :to => b, :total => number_with_delimiter(total), :query => q
    p_sum = content_tag(:p, summary)
    logo = show_logo ? image_tag("binglogo_#{I18n.locale}.gif", :style=>"float:right") : ""
    content_tag(:div, raw(logo + p_sum), :id => "summary")
  end

  def agency_url_matches_by_locale(result_url, agency, locale)
    agency.agency_urls.find_by_url_and_locale(result_url, locale.to_s).nil? ? false : true
  end

  def display_agency_phone_numbers(agency)
    html = ""
    html << "<h3 style=\"margin-top: 5px;\">#{t :agency_phone_label}: #{agency.phone}</h3>" if agency.phone.present?
    html << "<h3 style=\"margin-top: 5px;\">#{t :agency_toll_free_phone_label}: #{agency.toll_free_phone}</h3>" if agency.toll_free_phone.present?
    html << "<h3 style=\"margin-top: 5px;\">#{t :agency_tty_phone_label}: #{agency.tty_phone}</h3>" if agency.tty_phone.present?
    return raw(html)
  end

  def display_agency_social_media_links(agency)
    list_html = ""
    Agency::SOCIAL_MEDIA_SERVICES.each do |service|
      profile_link = agency.send("#{service.downcase}_profile_link".to_sym)
      list_html << "<h3>#{service}#{I18n.locale == I18n.default_locale ? ":" : " (en inglés):"} #{ link_to profile_link, profile_link, :target => "_blank" }</h3>" if profile_link
    end
    raw(list_html)
  end

  def advanced_search_link(search_options, affiliate = nil)
    search_options ||= {}
    search_options.merge!(:action => 'advanced', :controller => 'searches', :format => nil)
    search_options.merge!(:affiliate => affiliate.name) if affiliate
    link_to((t :advanced_search), advanced_search_path(search_options), :id => 'advanced_search_link')
  end

  def web_search?
    ["searches", "home"].include?(controller.controller_name) and controller.action_name == "index"
  end

  def image_search?
    controller.controller_name == "image_searches" or controller.controller_name == "images"
  end

  def recalls_search?
    controller.controller_name == "recalls"
  end

  def forms_search?
    (controller.controller_name == "searches" and controller.action_name == "forms") or controller.controller_name == "forms"
  end

  def no_results_for(query)
    content_tag(:p, (t :no_results_for, :query => query), :class=>"noresults")
  end

  def search_results_logo
    if forms_search?
      link_to image_tag("USAsearch_medium_#{I18n.locale}_forms.gif", :alt => "USASearch Forms Home"), forms_path(:locale => I18n.locale)
    else
      link_to image_tag("USAsearch_medium_#{I18n.locale}.gif", :alt => "USASearch Home"), home_page_path(:locale => I18n.locale)
    end
  end

  EN_SCOPE_ID_OPTIONS = [
    ['All Government Domains', 'all'],
    ['Federally-Focused', 'federal'],
    ['Non-Federal', 'nonfed'],
    ['Tribal Sites', 'tribal'],
    ['US territories', 'territories'],
    ['Alabama', 'AL'],
    ['Alaska', 'AK'],
    ['Arizona', 'AZ'],
    ['Arkansas', 'AR'],
    ['California', 'CA'],
    ['Colorado', 'CO'],
    ['Connecticut', 'CT'],
    ['D.C.', 'DC'],
    ['Delaware', 'DE'],
    ['Florida', 'FL'],
    ['Georgia', 'GA'],
    ['Hawaii', 'HI'],
    ['Idaho', 'ID'],
    ['Illinois', 'IL'],
    ['Indiana', 'IN'],
    ['Iowa', 'IA'],
    ['Kansas', 'KS'],
    ['Kentucky', 'KY'],
    ['Louisiana', 'LA'],
    ['Maine', 'ME'],
    ['Maryland', 'MD'],
    ['Massachusetts', 'MA'],
    ['Michigan', 'MI'],
    ['Minnesota', 'MN'],
    ['Mississippi', 'MS'],
    ['Missouri', 'MO'],
    ['Montana', 'MT'],
    ['Nebraska', 'NE'],
    ['Nevada', 'NV'],
    ['New Hampshire', 'NH'],
    ['New Jersey', 'NJ'],
    ['New Mexico', 'NM'],
    ['New York', 'NY'],
    ['North Carolina', 'NC'],
    ['North Dakota', 'ND'],
    ['Ohio', 'OH'],
    ['Oklahoma', 'OK'],
    ['Oregon', 'OR'],
    ['Pennsylvania', 'PA'],
    ['Rhode Island', 'RI'],
    ['South Carolina', 'SC'],
    ['South Dakota', 'SD'],
    ['Tennessee', 'TN'],
    ['Texas', 'TX'],
    ['Utah', 'UT'],
    ['Vermont', 'VT'],
    ['Virginia', 'VA'],
    ['Washington', 'WA'],
    ['West Virginia', 'WV'],
    ['Wisconsin', 'WI'],
    ['Wyoming', 'WY'],
    ['American Samoa', 'SA'],
    ['Guam', 'GU'],
    ['Mariana Islands', 'MP'],
    ['Marshall Islands', 'MH'],
    ['Micronesia', 'micronesia'],
    ['Puerto Rico', 'PR'],
    ['Virgin Islands', 'VI']
  ]

  ES_SCOPE_ID_OPTIONS = [
    ['a nivel federal y estatal', 'all'],
    ['a nivel federal', 'federal'],
    ['a nivel estatal', 'nonfed'],
    ['a nivel territorial', 'territories'],
    ['Alabama', 'AL'],
    ['Alaska', 'AK'],
    ['Arizona', 'AZ'],
    ['Arkansas', 'AR'],
    ['California', 'CA'],
    ['Carolina del Norte', 'NC'],
    ['Carolina del Sur', 'SC'],
    ['Colorado', 'CO'],
    ['Connecticut', 'CT'],
    ['Dakota del Norte', 'ND'],
    ['Dakota del Sur', 'SD'],
    ['D.C.', 'DC'],
    ['Delaware', 'DE'],
    ['Florida', 'FL'],
    ['Georgia', 'GA'],
    ['Hawaii', 'HI'],
    ['Idaho', 'ID'],
    ['Illinois', 'IL'],
    ['Indiana', 'IN'],
    ['Iowa', 'IA'],
    ['Kansas', 'KS'],
    ['Kentucky', 'KY'],
    ['Luisiana', 'LA'],
    ['Maine', 'ME'],
    ['Maryland', 'MD'],
    ['Massachusets', 'MA'],
    ['Michigan', 'MI'],
    ['Minesota', 'MN'],
    ['Misisipi', 'MS'],
    ['Misuri', 'MO'],
    ['Montana', 'MT'],
    ['Nebraska', 'NE'],
    ['Nevada', 'NV'],
    ['Nuevo Hampshire', 'NH'],
    ['Nuevo Jersey', 'NJ'],
    ['Nuevo Mexico', 'NM'],
    ['Nuevo York', 'NY'],
    ['Ohio', 'OH'],
    ['Oklahoma', 'OK'],
    ['Oregón', 'OR'],
    ['Pensilvania', 'PA'],
    ['Rhode Island', 'RI'],
    ['South Carolina', 'SC'],
    ['South Dakota', 'SD'],
    ['Tennessee', 'TN'],
    ['Texas', 'TX'],
    ['Utah', 'UT'],
    ['Vermont', 'VT'],
    ['Virginia', 'VA'],
    ['Virginia Occidental', 'WV'],
    ['Washington', 'WA'],
    ['Wisconsin', 'WI'],
    ['Wyoming', 'WY'],
    ['Estados Federados de Micronesia', 'micronesia'],
    ['Guam', 'GU'],
    ['Islas Mariana', 'MP'],
    ['Islas Marshall', 'MH'],
    ['Islas Vírgenes, EE.UU.', 'VI'],
    ['Puerto Rico', 'PR'],
    ['Samoa Americana', 'SA']
  ]

  def scope_ids_as_options
    if I18n.locale == :es
      ES_SCOPE_ID_OPTIONS
    else
      EN_SCOPE_ID_OPTIONS
    end
  end

  def search_meta_tags
    content = ''
    if english_locale? or spanish_locale?
      content << tag(:meta, {:name => "description", :content => t(:web_meta_description)})
      content << tag(:meta, {:name => "keywords", :content => t(:web_meta_keywords)})
    end
    raw content
  end

  def image_search_meta_tags
    content = ''
    if english_locale? or spanish_locale?
      content << tag(:meta, {:name => "description", :content => t(:image_meta_description)})
      content << tag(:meta, {:name => "keywords", :content => t(:image_meta_keywords)})
    end
    raw content
  end

  def path_to_search(search_params, path_to_landing_page, path_to_serp)
    search_params[:query].blank? ? path_to_landing_page : path_to_serp
  end


  def path_to_image_search(search_params)
    search_params[:query].blank? ? images_path(search_params) : image_search_path(search_params)
  end

  def path_to_search_in_other_locale_for(query)
    path = ''
    if query.blank?
      path = web_search? ? home_page_path(:locale => other_locale_str) : images_path(:locale => other_locale_str)
    else
      path = web_search? ? search_path(:locale => other_locale_str, :query => query) : image_search_path(:locale => other_locale_str, :query => query)
    end
    link_to(t(:search_in), path, :id => 'search_in_link')
  end

  def top_search_link_for(top_search)
    if top_search.url.blank?
      query_params = {
          :query => top_search.query,
          :linked => 1,
          :position => top_search.position,
          :locale => nil,
          :m => nil
      }
      path_or_url = search_path(query_params)
    else
      path_or_url = top_search.url
    end
    link_to top_search.query, path_or_url, :target => '_top'
  end

  def results_restriction_message_for(fedstates, search_path)
    heading = t :search_results_restriction_message_front, :scope_setting => fedstates
    link = link_to((t :search_results_restriction_message_link), search_path)
    raw(heading + ' ' + link)
  end

  private

  def shorten_url (url, length=30)
    return url if url.length <= length
    if url.count('/') >= 4
      if url.index('?')
        arr = url[0..url.index('?')].split('/')
        arr[arr.size - 1] += url[url.index('?') + 1..-1]
      else
        arr = url.split('/')
      end
      host = arr[0]+"//"+arr[2]
      if arr.last.index('?')
        doc_path = arr.last.split('?')
        doc = [doc_path.first, "?", doc_path[1].split('&').first, "..."].join
      else
        doc = arr.last.split('?').first
      end
      [host, "...", doc].join('/')
    else
      url[0, length]+"..."
    end
  end
end
