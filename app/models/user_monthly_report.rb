class UserMonthlyReport
  attr_reader :report_date, :affiliate_stats, :total_stats

  def initialize(user, report_date)
    @report_date = report_date
    last_month = @report_date - 1.month
    last_year = @report_date - 1.year
    @affiliate_stats = Hash.new
    user.affiliates.each do |affiliate|
      stats = {}
      stats[:affiliate] = affiliate
      stats[:total_queries] = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month, affiliate.name)
      stats[:total_clicks] = DailySearchModuleStat.where(day: @report_date.beginning_of_month..@report_date.end_of_month,
                                                         affiliate_name: affiliate.name).sum(:clicks)
      stats[:last_month_total_queries] = DailyUsageStat.monthly_totals(last_month.year, last_month.month, affiliate.name)
      stats[:last_year_total_queries] = DailyUsageStat.monthly_totals(last_year.year, last_year.month, affiliate.name)
      stats[:last_month_percent_change] = calculate_percent_change(stats[:total_queries], stats[:last_month_total_queries])
      stats[:last_year_percent_change] = calculate_percent_change(stats[:total_queries], stats[:last_year_total_queries])
      stats[:popular_queries] = DailyQueryStat.most_popular_terms(affiliate.name, @report_date.beginning_of_month, @report_date.end_of_month, 10)
      @affiliate_stats[affiliate.name] = stats
    end
    @total_stats = { :total_queries => 0, :total_clicks => 0, :last_month_total_queries => 0, :last_year_total_queries => 0 }
    @affiliate_stats.each do |aff, affiliate_stats|
      @total_stats[:total_queries] += affiliate_stats[:total_queries]
      @total_stats[:total_clicks] += affiliate_stats[:total_clicks]
      @total_stats[:last_month_total_queries] += affiliate_stats[:last_month_total_queries]
      @total_stats[:last_year_total_queries] += affiliate_stats[:last_year_total_queries]
    end
    @total_stats[:last_month_percent_change] = calculate_percent_change(@total_stats[:total_queries], @total_stats[:last_month_total_queries])
    @total_stats[:last_year_percent_change] = calculate_percent_change(@total_stats[:total_queries], @total_stats[:last_year_total_queries])
  end

  private

  def calculate_percent_change(current_value, previous_value)
    (previous_value != 0 ? (current_value.to_f - previous_value.to_f) / previous_value.to_f : 0) * 100
  end

end