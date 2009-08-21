module SearchHelper
  def display_result_links (result)
    url = shorten_url "#{result['unescapedUrl']}"
    html = link_to("#{h url}" , "#{h result['unescapedUrl']}")
    unless result['cacheUrl'].blank?
      html << " - "
      html << link_to("Cached" , "#{result['cacheUrl']}")
    end
    html
  end

  def display_result_title (result)
    link_to "#{result['title']}" , "#{h result['unescapedUrl']}"
  end

  private
  def shorten_url (url)
    return url if url.length <=30 or url.count('/') < 4
    arr = url.split('/')
    host= arr[0]+"//"+arr[2]
    doc = arr.last.split('?').first
    [host,"...",doc].join('/')
  end
end