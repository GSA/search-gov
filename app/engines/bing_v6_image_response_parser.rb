class BingV6ImageResponseParser < BingV6ResponseParser
  def results
    @results ||= bing_response_body.value.map { |v| individual_result(v) }
  end

  def total
    bing_response_body.total_estimated_matches
  end

  private

  def individual_result(bing_result)
    Hashie::Mash::Rash.new({
      title: bing_result.name,
      url: bing_result.host_page_url,
      media_url: bing_result.content_url,
      display_url: bing_result.host_page_display_url,
      content_type: "image/#{bing_result.encoding_format}",
      file_size: bing_result.content_size.to_i,
      width: bing_result.width,
      height: bing_result.height,
      thumbnail: {
        url: bing_result.thumbnail_url,
        content_type: nil,
        file_size: nil,
        width: bing_result.thumbnail.width,
        height: bing_result.thumbnail.height,
      },
    })
  end

  def default_bing_response_parts
    {
      _type: nil,
      next_offset: nil,
      total_estimated_matches: 0,
      value: [],
    }
  end

  def spelling_suggestion
    nil
  end
end
