class RtuQueryRawHumanArray < RtuPopularRawHumanArray
  def query_class
    RtuTopQueries
  end

  def aggs_field
    'raw'
  end

  def top_queries
    most_popular
  end
end
