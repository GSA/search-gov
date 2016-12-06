class ApiAzureCompositeImageSearch < ApiAzureCompositeSearch
  def default_module_tag
    is_api_key_bing_v5? ? 'BV5I' : 'AZCI'
  end

  def as_json(_options = {})
    {
      images: {
        total: @total,
        next_offset: @next_offset,
        results: as_json_results_to_hash,
      }.tap do |h|
        h[:spelling_suggestion] = @spelling_suggestion if @spelling_suggestion
      end
    }
  end

  def as_json_result_hash(result)
    {
      title: result.title,
      url: result.source_url,
      media_url: result.media_url,
      display_url: result.display_url,
      content_type: result.content_type,
      file_size: result.file_size,
      width: result.width,
      height: result.height,
      thumbnail: {
        url: result.thumbnail.media_url,
        content_type: result.thumbnail.content_type,
        file_size: result.thumbnail.file_size,
        width: result.thumbnail.width,
        height: result.thumbnail.height,
      },
    }
  end

  private

  def is_image_search?
    true
  end
end
