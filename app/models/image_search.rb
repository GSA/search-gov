class ImageSearch < WebSearch
  
  attr_reader :flickr_results

  def initialize(options = {})
    super(options)
    @bing_search = BingImageSearch.new(USER_AGENT)
    @sources = "Spell+Image"
  end

  protected

  def search
    begin
      @affiliate.flickr_photos.any? ? perform_odie_image_search : parse_bing_response(perform_bing_search)
    rescue BingSearch::BingSearchError => error
      Rails.logger.warn "Error getting search results from Bing server: #{error}"
      false
    end
  end
  
  def perform_odie_image_search
    odie_image_search = OdieImageSearch.new(@options)
    odie_image_search.run
    if odie_image_search.total == 0
      parse_bing_response(perform_bing_search)
    else
      odie_image_search
    end
  end

  def handle_response(response)
    response.is_a?(OdieImageSearch) ? handle_odie_response(response) : handle_bing_response(response)
  end
  
  def handle_odie_response(response)
    unless response.nil? and response.total > 0
      @total = response.total
      @results = response.results
      @startrecord = response.startrecord
      @endrecord = response.endrecord
    end
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