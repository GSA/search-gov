module SearchHelper
  def result_partial_for(search)
    if search.is_a?(ImageSearch)
      "/image_searches/result"
    else
      "/searches/result"
    end
  end

  def thumbnail_image_link(result)
    link_to thumbnail_image_tag(result),
            result["Url"],
            :alt => result["title"],
            :rel => "no-follow"
  end

  def thumbnail_image_tag(result)
    image_tag result["Thumbnail"]["Url"],
              :width  => result["Thumbnail"]["Width"],
              :height => result["Thumbnail"]["Height"],
              :title  => result["title"]
  end

  def thumbnail_link(result)
    link = URI.parse(result["Url"]).host rescue shorten_url(result["Url"])
    link_to link, result["MediaUrl"], :rel => "no-follow"
  end

  def display_result_links (result, search, affiliate, position)
    html = tracked_click_link(result['unescapedUrl'], shorten_url(result['unescapedUrl']), search, affiliate, position, 'BWEB')
    unless result['cacheUrl'].blank?
      html << " - "
      html << link_to((t :cached), "#{h result['cacheUrl']}", :class => 'cache_link')
    end
    html
  end

  def display_deep_links_for(result)
    return if result["deepLinks"].nil?
    rows = []
    result["deepLinks"].in_groups_of(2)[0, 4].each do |row_pair|
      row = content_tag(:td, row_pair[0].nil? ? "" : link_to((h row_pair[0].title), row_pair[0].url))
      row << content_tag(:td, row_pair[1].nil? ? "" : link_to((h row_pair[1].title), row_pair[1].url))
      rows << content_tag(:tr, row)
    end
    content_tag(:table, rows, :class=>"deep_links")
  end

  def display_result_title (result, search, affiliate, position)
    tracked_click_link(result['unescapedUrl'], translate_bing_highlights(h(result['title'])),search, affiliate, position, 'BWEB')
  end

  def tracked_click_link(url, title, search, affiliate, position, source)
    aff_name = affiliate.name rescue ""
    query = search.query.gsub("'", "\\\\'")
    "<a href=\"#{url}\" onmousedown=\"return click('#{query}',this.href, #{position + 1}, '#{aff_name}', '#{source}', #{search.queried_at_seconds})\">#{title}</a>"
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

  def unescaped_text_field_with_auto_complete(object, method, tag_options = {}, completion_options = {})
    tfwac = text_field_with_auto_complete(object, method, tag_options, completion_options)
    tfwac.gsub("&amp;", "&")
  end

  def shunt_from_bing_to_usasearch(bingurl, affiliate)
    query = CGI::unescape(bingurl.split("?q=").last)
    opts = {:query=> query}
    opts.merge!(:affiliate => affiliate.name) if affiliate
    search_path(opts)
  end

  def spelling_suggestion(search, affiliate)
    if (search.spelling_suggestion)
      escaped_spelling_suggestion = h(search.spelling_suggestion)
      rendered_suggestion = translate_bing_highlights(escaped_spelling_suggestion)
      suggestion_for_url = strip_bing_highlights(escaped_spelling_suggestion)
      opts = {:query=> suggestion_for_url}
      opts.merge!(:affiliate => affiliate.name) if affiliate
      url = image_search? ? image_search_path(opts): search_path(opts)
      content_tag(:h4, "#{t :did_you_mean}: #{tracked_click_link(url, rendered_suggestion, search, affiliate, 0, 'BSPEL')}")
    end
  end

  def results_summary(a, b, total, q, show_logo = true)
    summary = t :results_summary, :from => a, :to => b, :total => number_with_delimiter(total), :query => q
    p_sum = content_tag(:p, summary)
    logo = show_logo ? image_tag("binglogo.gif", :style=>"float:right") : ""
    content_tag(:div, logo + p_sum, :id => "summary")
  end

  def web_search?
    ["searches", "home"].include?(controller.controller_name)
  end

  def image_search?
    controller.controller_name == "image_searches"
  end

  def no_results_for(query)
    content_tag(:p, (t :no_results_for, :query => h(query)), :class=>"noresults")
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
    ['Virgina', 'VA'],
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
    ['Virgina', 'VA'],
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

  private
  def shorten_url (url)
    return url if url.length <=30
    if url.count('/') >= 4
      arr = url.split('/')
      host= arr[0]+"//"+arr[2]
      doc = arr.last.split('?').first
      [host, "...", doc].join('/')
    else
      url[0, 30]+"..."
    end
  end
end
