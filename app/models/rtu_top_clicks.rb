class RtuTopClicks < RtuTopN

  def initialize(query_body, filter_bots = false)
    super(query_body, 'click', filter_bots)
  end

end
