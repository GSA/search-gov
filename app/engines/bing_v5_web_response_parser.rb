class BingV5WebResponseParser < BingWebResponseParser
  private

  def individual_result(bing_result)
    super.merge({
      description: bing_result.snippet,
      display_url: StringProcessor.strip_highlights(bing_result.display_url),
      url: bing_result.url,
    })
  end
end
