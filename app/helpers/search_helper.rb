module SearchHelper

  SPECIAL_URL_PATH_EXT_NAMES = %w{doc pdf ppt ps rtf swf txt xls}

  NO_RESULTS_BANNERS = [
      { :image_path => 'no_results/no_results_1.jpg',
        :url_text => 'Library of Congress',
        :url => 'http://blogs.loc.gov/law/2010/09/do-you-remember-how-to-use-a-card-catalog/' },
      { :image_path => 'no_results/no_results_2.jpg',
        :url_text => 'Oregon State Library',
        :url => 'http://www.oregon.gov/OSL/photos_1930_1941.shtml' },
      { :image_path => 'no_results/no_results_3.jpg',
        :url_text => 'NOAA Photo Library',
        :url => 'http://www.photolib.noaa.gov/htmls/theb1805.htm' },
      { :image_path => 'no_results/no_results_4.jpg',
        :url_text => 'Oregon State Library',
        :url => 'http://www.oregon.gov/OSL/photos_1930_1941.shtml' },
      { :image_path => 'no_results/no_results_5.jpg',
        :url_text => 'Naval Historical Center',
        :url => 'http://www.history.navy.mil/photos/images/h97000/h97134c.htm' }
  ]

  def result_partial_for(search)
    if search.is_a?(ImageSearch)
      "/image_searches/result"
    else
      "/searches/result"
    end
  end

  def display_bing_image_result_links(result, search, affiliate, index, vertical)
    affiliate_name = affiliate.name rescue ""
    query = search.spelling_suggestion ? search.spelling_suggestion : search.query
    onmousedown_attribute = onmousedown_attribute_for_image_click(query, result["MediaUrl"], index, affiliate_name, "IMAG", search.queried_at_seconds, vertical)
    html = tracked_click_thumbnail_image_link(result, onmousedown_attribute)
    raw html << tracked_click_thumbnail_link(result, onmousedown_attribute)
  end

  def display_thumbnail_image_link(result, search, index, vertical, max_width = nil, max_height = nil)
    onmousedown_attribute = onmousedown_attribute_for_image_click(search.query, result["MediaUrl"], index, nil, "IMAG", search.queried_at_seconds, vertical)
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
    link_to link, result["MediaUrl"], :onmousedown => onmousedown_attr, :rel => "no-follow"
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

  def display_bing_result_links (result, search, affiliate, position, vertical, show_cache_link = true)
    html = tracked_click_link(h(result['unescapedUrl']), h(shorten_url(result['unescapedUrl'])), search, affiliate, position, 'BWEB', vertical, "class='link-to-full-url'")
    unless result['cacheUrl'].blank? or !show_cache_link
      html << " - "
      html << link_to((t :cached), "#{result['cacheUrl']}", :class => 'cache_link')
    end
    raw html
  end

  def display_search_within_this_site_link(result, search, affiliate)
    return '' if affiliate.nil? or I18n.locale == :es or search.matching_site_limit.present? or !affiliate.has_multiple_domains?
    site_limit = URI.parse(result['unescapedUrl']).host rescue nil
    html = ''
    site_limit.blank? ? '' : html << ' - ' << link_to('Search this site',
                                                      search_path(params.merge(:affiliate => affiliate.name,
                                                                               :locale => I18n.locale,
                                                                               :query => search.query,
                                                                               :sitelimit => site_limit)),
                                                      :class => 'search-this-site')
    raw html
  end

  def display_agency_link(result, search, affiliate, position, vertical)
    link_title = strip_url_protocol(shorten_url(result['unescapedUrl']))
    tracked_click_link(h(result['unescapedUrl']), h(link_title), search, affiliate, position, 'BWEB', vertical, "class='link-to-full-url'")
  end

  def display_agency_popular_links(popular_urls, search, affiliate, vertical)
    titles = popular_urls.collect{|popular_url| popular_url.title }
    duplicate_titles = titles.inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
    duplicate_counters = {}
    popular_links = []
    popular_urls.each_with_index do |popular_url, index|
      if duplicate_titles.include?(popular_url.title)
        dup_count = duplicate_counters[popular_url.title]
        if dup_count.nil?
          title = popular_url.title.truncate(46, :separator => " ") + " (1)"
          duplicate_counters[popular_url.title] = 1
        else
          title = popular_url.title.truncate(46, :separator => " ") + " (#{dup_count + 1})"
          duplicate_counters[popular_url.title] = dup_count + 1
        end
      else
        title = popular_url.title.truncate(50, :separator => " ")
      end
      popular_links << content_tag(:li, display_agency_popular_url(title, popular_url.url, search, affiliate, index, vertical))
    end
    html = content_tag(:ul, raw(popular_links))
  end

  def display_agency_popular_url(title, url, search, affiliate, position, vertical)
    tracked_click_link(h(url), h(title), search, affiliate, position, 'APOP', vertical)
  end

  def strip_url_protocol(url)
    url.gsub(/^http(s)?:\/\//, '')
  end

  def display_deep_links_for(result, search, affiliate, vertical)
    return if result["deepLinks"].nil?
    rows = []
    deep_links_are_all_pos_zero = 0
    result["deepLinks"].in_groups_of(2)[0, 4].each do |row_pair|
      row =  content_tag(:td, row_pair[0].nil? ? "" : tracked_click_link(h(row_pair[0].url), h(row_pair[0].title), search, affiliate, deep_links_are_all_pos_zero, 'BWEB', vertical))
      row << content_tag(:td, row_pair[1].nil? ? "" : tracked_click_link(h(row_pair[1].url), h(row_pair[1].title), search, affiliate, deep_links_are_all_pos_zero, 'BWEB', vertical))
      rows << content_tag(:tr, row)
    end
    content_tag(:table, raw(rows), :class=>"deep-links")
  end

  def display_bing_result_extname_prefix(bing_result)
    display_result_extname_prefix(bing_result['unescapedUrl'])
  end

  def display_result_extname_prefix(url)
    begin
      path_extname = File.extname(URI.parse(url).path)[1..-1]
      if SPECIAL_URL_PATH_EXT_NAMES.include?( path_extname.downcase )
        raw "<span class=\"uext_type\">[#{path_extname.upcase}]</span> "
      else
        ""
      end
    rescue
      ""
    end
  end

  def excluded_highlight_terms(affiliate, query)
    excluded_domains = affiliate.present? ? affiliate.domains_as_array : []
    excluded_domains.reject!{|domain| query =~ /#{domain}/ } if query.present?
    excluded_keywords = affiliate.present? ? affiliate.scope_keywords_as_array : []
    excluded_keywords.reject!{|keyword| query =~ /#{keyword}/i} if query.present?
    excluded_domains + excluded_keywords
  end

  def display_bing_result_title(result, search, affiliate, position, vertical)
    raw tracked_click_link(h(result['unescapedUrl']), translate_bing_highlights(h(result['title']), excluded_highlight_terms(affiliate, search.query)), search, affiliate, position, 'BWEB', vertical)
  end

  def display_medline_result_title(search, affiliate)
    raw tracked_click_link(h(search.med_topic.medline_url), highlight_string(h(search.med_topic.medline_title)), search, affiliate, 0, "MEDL")
  end

  def display_medline_topic_with_click_tracking(med_topic, query, locale, affiliate)
    onmousedown = onmousedown_for_click(query, 0, nil, 'MEDL', Time.now.to_i, :web)
    affiliate_name = affiliate.name if affiliate
    raw "<a href=\"#{h search_path(:affiliate => affiliate_name, :query => med_topic.medline_title, :locale => locale)}\" #{onmousedown}>#{med_topic.medline_title}</a>"
  end

  def display_medline_clinical_trail_with_click_tracking(mesh_title, query)
    onmousedown = onmousedown_for_click(query, 0, nil, 'MEDL', Time.now.to_i, :web)
    raw "<a href=\"http://clinicaltrials.gov/search/open/condition=#{URI.escape("\"" + h(mesh_title) + "\"")}\" #{onmousedown}>#{mesh_title}</a>"
  end

  def highlight_string(s)
    "<strong>#{s}</strong>".html_safe
  end

  def display_recall_result_url_with_click_tracking(recall_url, query, position, vertical)
    onmousedown = onmousedown_for_click(query, position, nil, 'RECALL', Time.now.to_i, vertical)
    raw "<a href=\"#{h recall_url}\" #{onmousedown}>#{shorten_url(recall_url)}</a>"
  end

  def display_recall_result_title_with_click_tracking(result, hit, query, position, vertical, summary_length)
    title= (highlight_like_solr(result.summary.truncate(summary_length, :separator => " "), hit.highlights)).html_safe
    onmousedown = onmousedown_for_click(query, position, nil, 'RECALL', Time.now.to_i, vertical)
    raw "<a href=\"#{h result.recall_url}\" #{onmousedown}>#{title}</a>"
  end

  def link_with_click_tracking(html_safe_title, url, affiliate, query, position, source, vertical, html_opts = nil)
    aff_name = affiliate.name rescue ""
    onmousedown = onmousedown_for_click(query, position, aff_name, source, Time.now.to_i, vertical)
    raw "<a href=\"#{h url}\" #{onmousedown} #{html_opts}>#{html_safe_title}</a>"
  end

  def boosted_content_link_with_click_tracking(html_safe_title, url, affiliate, query, position, vertical)
    link_with_click_tracking(html_safe_title, url, affiliate, query, position, "BOOS", vertical)
  end

  def featured_collection_link_with_click_tracking(title, url, affiliate, query, position, vertical)
    return title if url.blank?
    link_with_click_tracking(title, url, affiliate, query, position, "BBG", vertical)
  end

  def tracked_click_link(url, title, search, affiliate, position, source, vertical = :web, opts = nil)
    aff_name = affiliate.nil? ? "" : affiliate.name
    query = search.spelling_suggestion || search.query
    query = query.gsub("'", "\\\\'")
    onmousedown = onmousedown_for_click(query, position, aff_name, source, search.queried_at_seconds, vertical)
    raw "<a href=\"#{url}\" #{onmousedown} #{opts}>#{title}</a>"
  end

  def onmousedown_for_click(query, zero_based_index, affiliate_name, source, queried_at, vertical)
    "onmousedown=\"return clk('#{h query}',this.href, #{zero_based_index + 1}, '#{affiliate_name}', '#{source}', #{queried_at}, '#{vertical}', '#{I18n.locale.to_s}')\""
  end

  def onmousedown_attribute_for_image_click(query, media_url, zero_based_index, affiliate_name, source, queried_at, vertical)
    "return clk('#{h(escape_javascript(query))}', '#{media_url}', #{zero_based_index + 1}, '#{affiliate_name}', '#{source}', #{queried_at}, '#{vertical}', '#{I18n.locale.to_s}')"
  end

  def display_result_description(result, query = nil, affiliate = nil)
    translate_bing_highlights(h(result['content']), excluded_highlight_terms(affiliate, query)).html_safe
  end

  def display_medline_results_description(summary, query)
    highlight(truncate_html_prose_on_words(summary, 300), query).html_safe
  end

  def news_description(hit)
    truncate_html_prose_on_words(highlight_hit(hit, :description), 255).sub(/^([^A-Z<])/,'...\1').html_safe
  end

  def translate_bing_highlights(body, excluded_terms = [])
    excluded_terms.each do |term|
      body.scan(/#{term}/i).each do |term_variant|
        body.gsub!(/\xEE\x80\x80#{term_variant}\xEE\x80\x81/, term_variant)
      end
    end
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

  def bing_spelling_suggestion_for(search, affiliate, vertical)
    if (search.spelling_suggestion)
      rendered_suggestion = translate_bing_highlights(search.spelling_suggestion)
      suggestion_for_url = strip_bing_highlights(search.spelling_suggestion)
      opts = {:query=> suggestion_for_url}
      opts.merge!(:affiliate => affiliate.name) if affiliate
      corrected_url = image_search? ? image_search_path(opts) : search_path(opts)
      opts.merge!(:query => "+#{search.query}")
      original_url = image_search? ? image_search_path(opts) : search_path(opts)
      did_you_mean = t :did_you_mean,
                       :assumed_term => tracked_click_link(corrected_url, h(rendered_suggestion), search, affiliate, 0, 'BSPEL', vertical, "style='font-weight:bold'"),
                       :term_as_typed => tracked_click_link(original_url, h(search.query), search, affiliate, 0, 'OVER', vertical, "style='font-style:italic'")
      content_tag(:h4, raw(did_you_mean), :class => 'did-you-mean')
    end
  end

  def results_summary(a, b, total, q)
    p_sum = make_summary_p(a, b, total, q)
    content_tag(:div, raw(p_sum), :id => "summary")
  end

  def indexed_docs_results_summary(a, b, total, query, affiliate)
    p_sum = make_summary_p(a, b, total, query)
    p_back = content_tag(:p, link_to(t(:back_to_all_affiliate_results, :affiliate_name => affiliate.display_name), search_path(:query => query, :affiliate => affiliate.name)))
    content_tag(:div, raw(p_sum + p_back), :id => "summary")
  end

  def make_summary_p(a, b, total, query)
    content_tag(:p, t(:results_summary, :from => a, :to => b, :total => number_with_delimiter(total), :query => query))
  end

  def agency_url_matches_by_locale(result_url, agency, locale)
    agency.agency_urls.find_by_url_and_locale(result_url, locale.to_s).nil? ? false : true
  end

  def display_agency_phone_numbers(agency)
    content = ""
    content << content_tag(:li, "#{agency.phone} (#{t :agency_phone_label})") if agency.phone.present?
    content << content_tag(:li, "#{agency.toll_free_phone} (#{t :agency_toll_free_phone_label})") if agency.toll_free_phone.present?
    content << content_tag(:li, "#{agency.tty_phone} (#{t :agency_tty_phone_label})") if agency.tty_phone.present?
    return content_tag :ul, content.html_safe
  end

  def display_agency_social_media_links(agency)
    list_html = ""
    Agency::SOCIAL_MEDIA_SERVICES.each do |service|
      profile_link = agency.send("#{service.downcase}_profile_link".to_sym)
      title = "#{service}#{spanish_locale? ? " (en inglés)" : ""}"
      list_html << content_tag(:li, link_to(title, profile_link, :title => title, :class => service.downcase)) unless profile_link.blank?
    end
    content_tag(:ul, list_html.html_safe, :class => 'social-media')
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

  def error_page?
    controller.controller_name == "errors"
  end

  def no_results_for(query)
    content_tag(:p, (t :no_results_for_and_try, :query => query), :class => "noresults")
  end

  def no_news_results_for(search)
    reset_filters_link = link_to(t(:remove_all_filters), search_path(:affiliate => search.affiliate.name, :query => search.query))
    time_filter = NewsItem::TIME_BASED_SEARCH_OPTIONS[params[:tbs]]
    time_filter_message = time_filter.blank? ? '' : " #{t("the_last_#{time_filter.to_s}".to_sym)}"
    no_results_message = "#{t(:no_results_for_query, :query => h(search.query))}#{time_filter_message}. "
    no_results_message << reset_filters_link.html_safe
    no_results_message << " #{t(:or_try_broader)}"
    content_tag(:p, no_results_message.html_safe, :class => "noresults")
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

  def top_search_url_for(top_search, url_options = {})
    if top_search.url.blank?
      query_params = {
          :query => top_search.query,
          :linked => 1,
          :position => top_search.position
      }
      query_params.merge!(:affiliate => top_search.affiliate.name) if top_search.affiliate
      url = search_url(query_params.merge(url_options))
    else
      url = top_search.url
    end
    url
  end

  def top_search_link_for(top_search, url_options = {}, html_options = {})
    link_to top_search.query, top_search_url_for(top_search, url_options), html_options.merge(:target => '_top')
  end

  def results_restriction_message_for(fedstates, search_path)
    heading = t :search_results_restriction_message_front, :scope_setting => fedstates
    link = link_to((t :search_results_restriction_message_link), search_path)
    raw(heading + ' ' + link)
  end

  def related_topics_header(affiliate, query)
    if affiliate
      related_topics_suffix = content_tag :span, "#{I18n.t :by} #{affiliate.display_name}", :class => 'recommended-by'
    else
      related_topics_suffix = content_tag :span, "#{I18n.t :related_topics_suffix}", :class => 'by-usa-gov'
    end
    "#{I18n.t :related_topics_prefix} #{h query} #{related_topics_suffix}".html_safe
  end

  def related_faqs_header(query)
    related_faqs_suffix = content_tag :span, "#{I18n.t:related_faqs_header_suffix}", :class => 'by-usa-gov'
    "#{h(I18n.t :related_faqs_header_prefix)} #{h query} #{related_faqs_suffix}".html_safe
  end

  def render_no_results_banner
    banner = NO_RESULTS_BANNERS.shuffle.first
    content_tag(:div, :class => "no-results-banner") do
      content = image_tag(banner[:image_path], :alt => '')
      content << content_tag(:div, :class => 'no-results-banner-source') do
        banner_source_content = []
        banner_source_content << content_tag(:span, %{#{t :"no_results.source"}: })
        banner_source_content << link_to(banner[:url_text], banner[:url])
        banner_source_content << content_tag(:span, t(:"in_english"), :class => 'in-english')
        banner_source_content.join("\n").html_safe
      end
      content
    end
  end

  def featured_collection_css_classes(featured_collection, initial_classes = %w( featured-collection searchresult ))
    css_classes = initial_classes
    css_class = ''
    css_class << featured_collection.layout.parameterize
    css_class << (featured_collection.image_file_name.present? ? '-with-image' : '-without-image')
    css_classes << css_class
    css_classes.join(" ")
  end

  def render_featured_collection_link_title(link, index, highlighted_link_titles)
    return link.title if highlighted_link_titles.blank? or highlighted_link_titles[index].blank?
    highlighted_link_titles[index].html_safe
  end

  def display_search_all_affiliate_sites_suggestion(search, affiliate)
    return unless affiliate and search.matching_site_limit.present?
    html = "We're including results for '#{h search.query}' from only #{h search.matching_site_limit}. "
    html << "Do you want to see results for "
    html << link_to("'#{h search.query}' from all sites", search_path(params.except(:sitelimit)))
    html << "?"
    raw content_tag(:h4, html.html_safe, :class => 'search-all-sites-suggestion')
  end

  def display_affiliate_favicon(affiliate)
    favicon_url = affiliate.favicon_url
    favicon_url.blank? ? '/favicon.ico' : favicon_url
  end

  def render_featured_collection_image(fc)
    begin
      unless fc.image_file_name.blank?
        content = []
        content << image_tag(fc.image.url(fc.has_one_column_layout? ? :medium : :small), :alt => fc.image_alt_text)
        unless fc.image_attribution.blank?
          content << content_tag(:span, I18n.t(:image))
          content << link_to_unless(fc.image_attribution_url.blank?, content_tag(:span, fc.image_attribution, :class => 'attribution'), fc.image_attribution_url)
        end
        content_tag(:div, content.join("\n").html_safe, :class => 'image')
      end
    rescue Exception
      nil
    end
  end

  private

  def shorten_url (url, length=42)
    if url.length <= length
      if url =~ /^http:\/\/[-a-zA-Z0-9.]+\//i
        if url.last == '/'
          url[7..-2]
        else
          url[7..-1]
        end
      else
        url
      end
    elsif url.count('/') >= 3

      qx = url.index('?')

      if qx
        arr = url[0 .. qx - 1].split('/')
        q = ["?", url[qx + 1 .. -1].split('&').first, "..."].join
        if q.length > length + 3
          q = q[0...length] + "..."
        end
      else
        arr = url.split('/')
        q = ""
      end

      if arr[0] == "http:" && arr[2] =~ /^[-a-z0-9.]+$/i
        host = arr[2]
        keep_protocol = false
      else
        host = arr[0]+"//"+arr[2]
        keep_protocol = true
      end

      doc_path = arr[3..-1]

      doc = if doc_path.size == 0
              if q.empty? && !keep_protocol
                ""
              else
                "/"
              end
            else
              head = 0
              tail = doc_path.length - 1
              path_length = doc_path.last.length + 5

              if path_length >= length + 5
                path_length = length + 5
                doc_path[tail] = doc_path[tail][0...length] + "..."
              end
              path_max_length = length - (host.length + q.length)

              while head < tail && ((path_length + doc_path[head].length + 1) < path_max_length)
                path_length += doc_path[head].length + 1
                head += 1
                if head < tail && ((path_length + doc_path[tail-1].length + 1) < path_max_length)
                  tail -= 1
                  path_length += doc_path[tail].length + 1
                end
              end

              if head == tail
                "/" + doc_path.join("/")
              elsif head == 0
               "/" + "..." + "/" + doc_path[tail..-1].join("/")
              else
               "/" + doc_path[0..head-1].join("/") + "/.../"+ doc_path[tail..-1].join("/")
              end
            end


      host + doc + q
    else
      url[0, length] + "..."
    end
  end
end
