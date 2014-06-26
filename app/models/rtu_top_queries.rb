class RtuTopQueries < RtuTopN

  def initialize(query_body, filter_bots, day = nil)
    super(query_body, 'search', filter_bots, day)
  end

end
