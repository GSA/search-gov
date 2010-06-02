class ImageSearch < Search
  SOURCES = "Spell+Image"

  def hits(response)
    response.image.total rescue 0
  end

  def process_results(response)
    response.image.results.collect do |result|
      {
        "title" => result.title,
        "Width" => result.width,
        "Height" => result.height,
        "FileSize" => result.fileSize,
        "ContentType" => result.contentType,
        "Url" => result.Url,
        "DisplayUrl" => result.displayUrl,
        "MediaUrl" => result.mediaUrl,
        "Thumbnail" => {
          "Url" => result.thumbnail.url,
          "FileSize" => result.thumbnail.fileSize,
          "Width" => result.thumbnail.width,
          "Height" => result.thumbnail.height,
          "ContentType" => result.thumbnail.contentType
        }
      }
    end
  end

  def bing_query(query_string, offset, count, enable_highlighting = true)
    params = [
      "image.offset=#{offset}",
      "image.count=#{count}",
      "AppId=#{APP_ID}",
      "sources=#{SOURCES}",
      "Options=#{ enable_highlighting ? "EnableHighlighting" : ""}",
      "query=#{URI.escape(query_string)}"
    ]
    "#{JSON_SITE}?" + params.join('&')
  end

  protected
  def populate_additional_results
  end  

end
