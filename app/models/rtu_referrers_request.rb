class RtuReferrersRequest
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

  def top_referrers
    @top_stats
  end

  private

  def compute_top_stats
    query = DateRangeTopNQuery.new(site.name, start_date, end_date, { field: 'referrer', size: MAX_RESULTS })
    rtu_top_stats = RtuTopQueries.new(query.body, filter_bots)
    rtu_top_stats.top_n
  end

end