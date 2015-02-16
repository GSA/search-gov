class ImpressionClickStat
  attr_reader :impressions, :clicks

  def initialize(impressions = 0, clicks = 0)
    @impressions, @clicks = impressions, clicks
  end

  def ctr
    100.0 * @clicks / @impressions
  end
end