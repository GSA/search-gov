class ImageSearch < WebSearch
  
  def initialize(options = {})
    super(options)
    @bing_search = BingImageSearch.new(USER_AGENT)
  end

  def as_json(options = {})
    if self.error_message
      {:error => self.error_message}
    else
      {:total => self.total, :startrecord => self.startrecord, :endrecord => self.endrecord, :results => self.results}
    end
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

  def bing_sources
    "Spell+Image"
  end
  
  def populate_additional_results(response)
  end

  def related_search_results
    []
  end
end