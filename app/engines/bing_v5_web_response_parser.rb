class BingV5WebResponseParser < BingV5ResponseParser
  def results
    @results ||= begin
      bing_response_body.web_pages.value.map do |bing_result|
        Hashie::Mash.new({
          title: bing_result.name,
          url: bing_result.url,
          description: bing_result.snippet,
        })
      end
    end
  end

  def total
    bing_response_body.web_pages.total_estimated_matches
  end

  private

  def default_bing_response_parts
    {
      query_context: {
        altered_query: nil,
      },
      status_code: 200,
      web_pages: {
        total_estimated_matches: 0,
        value: [],
      },
    }
  end
end
