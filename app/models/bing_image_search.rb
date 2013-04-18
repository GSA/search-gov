class BingImageSearch < BingSearch
  protected

  def params
    params_hash = super
    params_hash.merge!('image.offset' => offset) unless offset== DEFAULT_OFFSET
    params_hash.merge!('image.count' => per_page) unless per_page == DEFAULT_PER_PAGE
    params_hash
  end

  def process_results(response)
    response.image.results || []
  end

  def hits(response)
    (response.image.results.blank? ? 0 : response.image.total) rescue 0
  end

  def bing_offset(response)
    response.image.offset rescue 0
  end

  def index_sources
    'Spell Image'
  end

end