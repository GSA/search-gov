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
    link_to URI.parse(result["Url"]).host, result["MediaUrl"], :rel => "no-follow"
  end

  def display_result_links (result, link = true)
    if false == link then
      return shorten_url(result['unescapedUrl'])
    end

    url = shorten_url "#{result['unescapedUrl']}"
    html = link_to(url, "#{h result['unescapedUrl']}")
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

  def display_result_title (result)
    link_to "#{translate_bing_highlights(h(result['title']))}", "#{h result['unescapedUrl']}"
  end

  def display_result_description (result)
    translate_bing_highlights(h(result['content']))
  end

  def translate_bing_highlights(body)
    body.gsub(/\xEE\x80\x80/, '<strong>').gsub(/\xEE\x80\x81/, '</strong>')
  end

  def shunt_from_bing_to_usasearch(bingurl, affiliate)
    query = CGI::unescape(bingurl.split("?q=").last)
    opts = {:query=> query}
    opts.merge!(:affiliate => affiliate.name) if affiliate
    search_path(opts)
  end

  def spelling_suggestion(spelling_suggestion, affiliate)
    if (spelling_suggestion)
      opts = {:query=> spelling_suggestion}
      opts.merge!(:affiliate => affiliate.name) if affiliate
      suggestion = translate_bing_highlights(h(spelling_suggestion))
      content_tag(:h4, "#{t :did_you_mean}: #{link_to(suggestion, search_path(opts))}")
    end
  end

  def results_summary(a, b, total, q, show_logo = true)
    summary = t :results_summary, :from => a, :to => b, :total => number_with_delimiter(total), :query => q
    p_sum = content_tag(:p, summary)
    logo = show_logo ? image_tag("binglogo.gif", :style=>"float:right") : ""
    container = content_tag(:div, logo + p_sum, :id => "summary")
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
