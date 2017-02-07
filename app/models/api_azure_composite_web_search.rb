class ApiAzureCompositeWebSearch < ApiAzureCompositeSearch
  def default_module_tag
    is_api_key_bing_v5? ? 'BV5W' : 'AZCW'
  end

  def as_json(_options = {})
    {
      web: {
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
      url: result.url,
      display_url: result.display_url,
      snippet: result.description,
    }
  end

  private

  def is_image_search?
    false
  end
end
