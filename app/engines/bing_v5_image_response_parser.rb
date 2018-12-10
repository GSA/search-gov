class BingV5ImageResponseParser < BingImageResponseParser
  private

  def individual_result(bing_result)
    super.merge({
      source_url: bing_result.host_page_url,
    }).tap do |h|
      h[:thumbnail].merge!({
        media_url: bing_result.thumbnail_url,
      })
    end
  end
end
