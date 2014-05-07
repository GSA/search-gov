class ElasticDailyQueryStatResults
  attr_reader :total, :ids

  def initialize(result)
    @total = result['hits']['total']
    @ids = result['hits']['hits'].collect { |hit| hit['_id'].to_i }
  end

end