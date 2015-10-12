class ApiAzureCompositeWebSearch < ApiAzureCompositeSearch
  self.default_module_tag = 'AZCW'.freeze

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
      snippet: result.description,
    }
  end
end
