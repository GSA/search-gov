class RtuClicksRequest
  MAX_RESULTS = 1000
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include RtuAnalyticsRequestable

  attr_reader :start_date, :end_date, :available_dates, :filter_bots

  attribute :site, Affiliate
  attribute :start_date, String
  attribute :end_date, String
  attribute :filter_bots, Boolean

  def top_urls
    @top_stats
  end

  private

  def compute_top_stats
    query = DateRangeTopNQuery.new(
      site.name,
      'click',
      start_date,
      end_date,
      { field: 'params.url', size: MAX_RESULTS }
    )
    rtu_top_clicks = RtuTopClicks.new(query.body, filter_bots)
    rtu_top_clicks.top_n
  end

end
