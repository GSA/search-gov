class UserMonthlyReport
  attr_reader :report_date, :affiliate_stats, :total_stats

  def initialize(user, report_date)
    @report_date = report_date
    @last_month = @report_date - 1.month
    @last_year = @report_date - 1.year
    @affiliate_stats = user.affiliates.inject({}) do |result, affiliate|
      result[affiliate.name] = calculate_affiliate_stats(affiliate)
      result
    end
    calculate_total_stats
  end

  private

  def calculate_affiliate_stats(affiliate)
    stats = {}
    stats[:affiliate] = affiliate
    recent_monthly_report = RtuMonthlyReport.new(affiliate, @report_date.year, @report_date.month, false)
    stats[:total_queries] = recent_monthly_report.total_queries
    stats[:total_clicks] = recent_monthly_report.total_clicks
    # Reminder: migrate from DailyUsageStat to RtuMonthlyReport in July 2014 for :last_month_total_queries
    stats[:last_month_total_queries] = DailyUsageStat.monthly_totals(@last_month.year, @last_month.month, affiliate.name)
    # Reminder: migrate from DailyUsageStat to ES data in June 2015 for :last_year_total_queries
    stats[:last_year_total_queries] = DailyUsageStat.monthly_totals(@last_year.year, @last_year.month, affiliate.name)
    stats[:last_month_percent_change] = calculate_percent_change(stats[:total_queries], stats[:last_month_total_queries])
    stats[:last_year_percent_change] = calculate_percent_change(stats[:total_queries], stats[:last_year_total_queries])
    stats[:popular_queries] = RtuQueryStat.most_popular_human_searches(affiliate.name, @report_date.beginning_of_month, @report_date.end_of_month, 10)
    stats
  end

  def calculate_total_stats
    @total_stats = { :total_queries => 0, :total_clicks => 0, :last_month_total_queries => 0, :last_year_total_queries => 0 }
    @affiliate_stats.each_value do |affiliate_stats|
      @total_stats[:total_queries] += affiliate_stats[:total_queries]
      @total_stats[:total_clicks] += affiliate_stats[:total_clicks]
      @total_stats[:last_month_total_queries] += affiliate_stats[:last_month_total_queries]
      @total_stats[:last_year_total_queries] += affiliate_stats[:last_year_total_queries]
    end
    @total_stats[:last_month_percent_change] = calculate_percent_change(@total_stats[:total_queries], @total_stats[:last_month_total_queries])
    @total_stats[:last_year_percent_change] = calculate_percent_change(@total_stats[:total_queries], @total_stats[:last_year_total_queries])
  end

  def calculate_percent_change(current_value, previous_value)
    (previous_value != 0 ? (current_value.to_f - previous_value.to_f) / previous_value.to_f : 0) * 100
  end

end