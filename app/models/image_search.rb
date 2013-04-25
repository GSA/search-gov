class ImageSearch < WebSearch
  protected

  def post_process_results(results)
    results.select { |result| result.thumbnail.present? }
  end

  def populate_additional_results
  end

  def odie_search_class
    OdieImageSearch
  end

  def get_vertical
    :image
  end

  def local_index_module_tag
    'FLICKR'
  end

  def module_tag_for_search_engine(search_engine)
    search_engine == 'Bing' ? 'IMAG' : 'GIMAG'
  end

end