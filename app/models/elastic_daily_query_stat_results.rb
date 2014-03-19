class ElasticDailyQueryStatResults
  attr_reader :total, :ids

  def initialize(hits, aggregations = nil)
    @total = hits['total']
    @ids = hits['hits'].collect { |hit| hit['_id'].to_i }
  end

end