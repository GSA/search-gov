class BingImageSearch < BingSearch
  
  protected
  
  def bing_api_url(query_string, query_sources, offset, count, enable_highlighting = true, filter_setting = DEFAULT_FILTER_SETTING)
    params = [
      "image.offset=#{offset}",
      "image.count=#{count}",
      "AppId=#{APP_ID}",
      "sources=#{query_sources}",
      "Options=#{ enable_highlighting ? "EnableHighlighting" : ""}",
      "query=#{URI.escape(query_string)}"
    ]
    "#{JSON_SITE}?" + params.join('&')
  end
end