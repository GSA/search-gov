class DailyUsageStat < ActiveRecord::Base
  validates_presence_of :day, :affiliate
  validates_uniqueness_of :day, :scope => :affiliate

  def self.most_recent_populated_date(affiliate_name)
    maximum(:day, :conditions => ['affiliate=?', affiliate_name])
  end

  def self.monthly_totals(year, month, affiliate_name = nil)
    report_date = Date.civil(year, month)
    if affiliate_name
      DailyUsageStat.sum(:total_queries, :conditions => [ "(day between ? and ?) AND affiliate = ?", report_date.beginning_of_month, report_date.end_of_month, affiliate_name ])
    else
      DailyUsageStat.sum(:total_queries, :conditions => [ "(day between ? and ?)", report_date.beginning_of_month, report_date.end_of_month ])
    end
  end
end
