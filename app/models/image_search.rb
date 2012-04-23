class ImageSearch < WebSearch

  def initialize(options = {})
    super(options)
    @bing_search = BingImageSearch.new(USER_AGENT)
    @sources = "Spell+Image"
  end

  protected

  def search
    begin
      parse_bing_response(perform_bing_search)
    rescue BingSearch::BingSearchError => error
      Rails.logger.warn "Error getting search results from Bing server: #{error}"
      false
    end
  end

  def handle_response(response)
    handle_bing_response(response)
  end

  def hits(response)
    response.image.total rescue 0
  end

  def bing_offset(response)
    response.image.offset rescue 0
  end

  def process_results(response)
    process_image_results(response)
  end

  def populate_additional_results
  end
end