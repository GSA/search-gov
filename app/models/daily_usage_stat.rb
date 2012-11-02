class DailyUsageStat < ActiveRecord::Base
  extend AffiliateDailyStats
  validates_presence_of :day, :affiliate
  validates_uniqueness_of :day, :scope => :affiliate

  def self.monthly_totals(year, month, affiliate_name = nil)
    report_date = Date.civil(year, month)
    affiliate_clause = affiliate_name ? "affiliate = '#{affiliate_name}' AND" : ""
    DailyUsageStat.sum(:total_queries, :conditions => ["#{affiliate_clause} (day between ? and ?)",
                                                       report_date.beginning_of_month, report_date.end_of_month])
  end
end
