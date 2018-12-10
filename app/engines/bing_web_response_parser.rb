class BingWebResponseParser < BingResponseParser
  def results
    @results ||= bing_response_body.web_pages.value.map { |v| individual_result(v) }
  end

  def total
    bing_response_body.web_pages.total_estimated_matches
  end

  private

  def default_bing_response_parts
    super.merge({
      web_pages: {
        total_estimated_matches: 0,
        value: [],
      },
    })
  end

  def individual_result(bing_result)
    Hashie::Mash.new({
      content: bing_result.snippet,
      title: bing_result.name,
      unescaped_url: bing_result.url,
    })
  end

  def spelling_suggestion
    bing_response_body.query_context.altered_query
  end
end
