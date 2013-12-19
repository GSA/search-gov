class ElasticResults
  attr_reader :total, :offset, :results

  def initialize(hits)
    @total = hits['total']
    @offset = hits['offset']
    @results = extract_results(hits['hits'])
  end

end
