class ImageSearch < WebSearch

  def initialize(options = {})
    super(options)
    @bing_search = BingImageSearch.new
    @sources = "Spell+Image"
  end

  protected

  def hits(response)
    (response.image.results.blank? ? 0 : response.image.total) rescue 0
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

  def assign_module_tag
    if @total > 0
      @module_tag = are_results_by_bing? ? 'IMAG' : 'FLICKR'
    else
      @module_tag = nil
    end
  end
end