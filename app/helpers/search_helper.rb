module SearchHelper
  def display_result_links (result)
    html = link_to("#{result['unescapedUrl']}" , "#{h result['unescapedUrl']}")
    html << " - "
    html << link_to("Cached" , "#{result['cacheUrl']}")
    html
  end

  def display_result_title (result)
    link_to "#{result['title']}" , "#{h result['unescapedUrl']}"
  end
end