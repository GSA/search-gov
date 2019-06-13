# frozen_string_literal: true

# Top clicks by count in a specified time period
class RtuTopClicks < RtuTopN
  def initialize(query_body, filter_bots, day = nil)
    super(query_body, 'click', filter_bots, day)
  end
end
