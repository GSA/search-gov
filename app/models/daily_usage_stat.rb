class DailyUsageStat < ActiveRecord::Base
  extend AffiliateDailyStats
  validates_presence_of :day, :affiliate
  validates_uniqueness_of :day, :scope => :affiliate

  def self.monthly_totals(year, month, affiliate_name = nil)
    report_date = Date.civil(year, month)
    conditions = {day: report_date.beginning_of_month..report_date.end_of_month}
    conditions.merge!(affiliate: affiliate_name) if affiliate_name.present?
    where(conditions).sum(:total_queries)
  end

  def self.monthly_usage_histogram(report_date)
    old_report_date = report_date - 1.month
    minimum_threshold = 100
    ActiveRecord::Base.connection.execute("select 10*bucket,count(*) cnt from (select case  when pct< -10 then -10 when pct>10 then 10 else pct end bucket from (select old.affiliate,round(10*(ifnull(new.cnt,0)- old.cnt)/old.cnt) pct from ( select affiliate, sum(total_queries) cnt from daily_usage_stats where day between '#{old_report_date.beginning_of_month}' and '#{old_report_date.end_of_month}' group by affiliate having cnt > #{minimum_threshold}) old left outer join ( select affiliate, sum(total_queries) cnt from daily_usage_stats where day between '#{report_date.beginning_of_month}' and '#{report_date.end_of_month}' group by affiliate ) new on old.affiliate=new.affiliate ) pcts ) buckets where not isnull(bucket) group by bucket").collect { |r| [r[0].to_i, r[1]] }
  end

  def self.total_queries(start_date, end_date)
    joins('LEFT OUTER JOIN affiliates ON daily_usage_stats.affiliate = affiliates.name').
      sum(:total_queries,
          conditions: ['daily_usage_stats.day BETWEEN ? AND ?', start_date, end_date],
          group: %w(daily_usage_stats.affiliate affiliates.id),
          order: '1 DESC')
  end
end
