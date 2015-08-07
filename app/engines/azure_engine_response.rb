class AzureEngineResponse < CommercialSearchEngineResponse
  def initialize(engine, azure_response)
    if azure_response.d &&
      azure_response.d.results.present?
      yield self
    else
      @results = []
    end

    @start_record = engine.azure_params.offset + 1
    @end_record = start_record + results.size - 1
  end
end
