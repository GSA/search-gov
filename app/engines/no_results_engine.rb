class NoResultsEngine < SearchEngine
  def execute_query
    Rails.logger.debug("NO RESULTS FOR YOU!")
    response = CommercialSearchEngineResponse.new
    response.total = 0
    response.results = []
    response.next_offset = 0
    response.diagnostics = { }
    response
  end
end
