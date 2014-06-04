class RtuTopQueries < RtuTopN

  def initialize(query_body, filter_bots = false)
    super(query_body, 'search', filter_bots)
  end

end
