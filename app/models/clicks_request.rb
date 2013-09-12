class ClicksRequest
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :start_date, :end_date, :top_urls, :available_dates

  attribute :site, Affiliate
  attribute :start_date, String
  attribute :end_date, String

  def persisted?
    false
  end

  def save
    @available_dates= DailyClickStat.available_dates_range(site.name)
    @end_date = end_date.nil? ? DailyClickStat.most_recent_populated_date(site.name) : end_date.to_date
    @start_date = start_date.nil? ? @end_date : start_date.to_date
    @top_urls = DailyClickStat.top_urls(site.name, @start_date, @end_date)
  end

end
