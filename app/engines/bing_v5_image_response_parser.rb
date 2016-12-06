class BingV5ImageResponseParser < BingV5ResponseParser
  def results
    @results ||= begin
      bing_response_body.value.map do |bing_result|
        Hashie::Mash.new({
          title: bing_result.name,
          source_url: bing_result.host_page_url,
          media_url: bing_result.content_url,
          display_url: bing_result.host_page_display_url,
          content_type: "image/#{bing_result.encoding_format}",
          file_size: bing_result.content_size.to_i,
          width: bing_result.width,
          height: bing_result.height,
          thumbnail: {
            media_url: bing_result.thumbnail_url,
            width: bing_result.thumbnail.width,
            height: bing_result.thumbnail.height,
          },
        })
      end
    end
  end

  def total
    bing_response_body.total_estimated_matches
  end

  def next_offset
    offset = super
    offset + bing_response_body.next_offset_add_count if offset
  end

  private

  def default_bing_response_parts
    {
      next_offset_add_count: 0,
      query_context: {
        altered_query: nil,
      },
      status_code: 200,
      total_estimated_matches: 0,
      value: [],
    }
  end
end
