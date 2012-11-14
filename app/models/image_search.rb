class ImageSearch < WebSearch

  def initialize(options = {})
    super(options)
    @bing_search = BingImageSearch.new
    @sources = "Spell+Image"
  end

  protected

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

  def odie_search_class
    OdieImageSearch
  end

  def get_vertical
    :image
  end

end