class RtuClickRawHumanArray < RtuPopularRawHumanArray
  def query_class
    RtuTopClicks
  end

  def aggs_field
    'params.url'
  end

  def top_clicks
    most_popular
  end

  def type
    'click'
  end
end
