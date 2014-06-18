class RtuClicksRequest
  MAX_RESULTS = 1000
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :start_date, :end_date, :top_urls, :available_dates, :filter_bots

  attribute :site, Affiliate
  attribute :start_date, String
  attribute :end_date, String
  attribute :filter_bots, Boolean

  def persisted?
    false
  end

  def save
    rtu_date_range = RtuDateRange.new(site.name, 'search')
    @available_dates = rtu_date_range.available_dates_range
    @end_date = end_date.nil? ? @available_dates.end : end_date.to_date
    @start_date = start_date.nil? ? (@end_date and @end_date.beginning_of_month) : start_date.to_date
    @top_urls = compute_top_url_stats
  end

  private

  def compute_top_url_stats
    query = DateRangeTopNQuery.new(site.name, start_date, end_date, { field: 'params.url', size: MAX_RESULTS })
    rtu_top_clicks = RtuTopClicks.new(query.body, filter_bots)
    rtu_top_clicks.top_n
  end

end
