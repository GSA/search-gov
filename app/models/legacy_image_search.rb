class LegacyImageSearch < WebSearch
  self.default_per_page = 20

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
    'OASIS'
  end

  def module_tag_for_search_engine
    'IMAG'
  end

  def social_image_feeds_checked?
    @affiliate.has_social_image_feeds?
  end

end
