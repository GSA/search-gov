class DailyUsageStat < ActiveRecord::Base
  validates_presence_of :day, :affiliate
  validates_uniqueness_of :day, :scope => :affiliate

  def self.most_recent_populated_date(affiliate_name)
    maximum(:day, :conditions => ['affiliate=?', affiliate_name])
  end

  def self.monthly_totals(year, month, affiliate_name = nil)
    total_monthly_queries(year, month, affiliate_name)
  end

  def self.total_monthly_queries(year, month, affiliate)
    sum_usage_stat_by_month(:total_queries, year, month, affiliate)
  end

  def self.sum_usage_stat_by_month(field, year, month, affiliate)
    report_date = Date.civil(year, month)
    if affiliate
      DailyUsageStat.sum(field, :conditions => [ "(day between ? and ?) AND affiliate = ?", report_date.beginning_of_month, report_date.end_of_month, affiliate ])
    else
      DailyUsageStat.sum(field, :conditions => [ "(day between ? and ?)", report_date.beginning_of_month, report_date.end_of_month ])
    end
  end
end
