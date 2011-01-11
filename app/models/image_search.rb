class ImageSearch < Search

  def hits(response)
    response.image.total rescue 0
  end

  def process_results(response)
    process_image_results(response)
  end

  def bing_query(query_string, query_sources, offset, count, enable_highlighting = true)
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

  def sources
    "Spell+Image"
  end

  def as_json(options = {})
    if self.error_message
      {:error => self.error_message}
    else
      {:total => self.total, :startrecord => self.startrecord, :endrecord => self.endrecord, :results => self.results}
    end
  end

  protected
  def populate_additional_results(response)
  end

end
