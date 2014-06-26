class DailyUsageStat < ActiveRecord::Base
  validates_presence_of :day, :affiliate
  validates_uniqueness_of :day, :scope => :affiliate

  def self.monthly_totals(year, month, affiliate_name)
    report_date = Date.civil(year, month)
    where(affiliate: affiliate_name, day: report_date.beginning_of_month..report_date.end_of_month).sum(:total_queries)
  end

end
