# frozen_string_literal: true

class RtuQueryRawHumanArray < RtuPopularRawHumanArray
  def query_class
    RtuTopQueries
  end

  def aggs_field
    'params.query.raw'
  end

  def top_queries
    most_popular
  end

  def type
    'search'
  end
end
