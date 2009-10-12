module SearchHelper
  def display_result_links (result)
    url = shorten_url "#{result['unescapedUrl']}"
    html = link_to("#{h url}", "#{h result['unescapedUrl']}")
    unless result['cacheUrl'].blank?
      html << " - "
      html << link_to("Cached", "#{result['cacheUrl']}")
    end
    html
  end

  def display_deep_links_for(result, query)
    return if result["deepLinks"].nil?
    rows = []
    result["deepLinks"].in_groups_of(2)[0, 4].each do |row_pair|
      row = content_tag(:td, row_pair[0].nil? ? "" : link_to(row_pair[0].title, row_pair[0].url))
      row << content_tag(:td, row_pair[1].nil? ? "" : link_to(row_pair[1].title, row_pair[1].url))
      rows << content_tag(:tr, row)
    end
    hostname_from_url = result['unescapedUrl'].split("/")[2]
    site_query = "site:#{hostname_from_url}"
    if !query.match(site_query)
      more_results_path = search_path(:query=> "#{site_query} #{query}")
      more_results_link = link_to "Show more results from #{hostname_from_url}", more_results_path, :class=>"more_results"
      rows << content_tag(:tr, content_tag(:td, more_results_link, :colspan=>2))
    end
    content_tag(:table, rows, :class=>"deep_links")
  end

  def display_result_title (result)
    link_to "#{result['title']}", "#{h result['unescapedUrl']}"
  end

  def highlight_except(str, exclude)
    ex_ary = exclude.downcase.split(' ')
    str.split(' ').map { |token| (ex_ary.include?token.downcase) ? token : "<strong>#{token}</strong>" }.join(" ")
  end

  def shunt_from_bing_to_usasearch(bingurl)
    query = CGI::unescape(bingurl.split("?q=").last)
    search_path(:query=> query)
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