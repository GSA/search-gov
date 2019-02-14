# frozen_string_literal: true

# Top clicks by count in a specified time period
class RtuTopClicks < RtuTopN
  def initialize(query_body, filter_bots, day = nil)
    super(query_body, 'click', filter_bots, day)
  end

  # Statistically significant clicks as determined by clicks representing a
  # given percentage of all clicks
  def top_clicks_to_percentage(percent)
    total_clicks = top_n.map(&:last).sum
    cumulative_clicks = 0.0
    top_n.select do |click|
      ((cumulative_clicks += click[1]) / total_clicks) * 100 < percent
    end
  end
end
