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
    recent_monthly_unfiltered_report = RtuMonthlyReport.new(affiliate, @report_date.year, @report_date.month, false)
    stats[:total_unfiltered_queries] = recent_monthly_unfiltered_report.total_queries
    recent_monthly_report = RtuMonthlyReport.new(affiliate, @report_date.year, @report_date.month, true)
    stats[:total_queries] = recent_monthly_report.total_queries
    stats[:total_clicks] = recent_monthly_report.total_clicks
    older_monthly_report = RtuMonthlyReport.new(affiliate, @last_month.year, @last_month.month, true)
    stats[:last_month_total_queries] = older_monthly_report.total_queries
    last_year_monthly_report = RtuMonthlyReport.new(affiliate, @last_year.year, @last_year.month, true)
    stats[:last_year_total_queries] = last_year_monthly_report.total_queries
    stats[:last_month_percent_change] = calculate_percent_change(stats[:total_queries], stats[:last_month_total_queries])
    stats[:last_year_percent_change] = calculate_percent_change(stats[:total_queries], stats[:last_year_total_queries])
    stats.merge(popular_activities(affiliate))
  end

  def popular_activities(affiliate)
    query_raw_human = RtuQueryRawHumanArray.new(affiliate.name, @report_date.beginning_of_month, @report_date.end_of_month)
    click_raw_human = RtuClickRawHumanArray.new(affiliate.name, @report_date.beginning_of_month, @report_date.end_of_month)

    {
      popular_queries: query_raw_human.top_queries,
      popular_clicks: click_raw_human.top_clicks,
    }
  end

  def calculate_total_stats
    @total_stats = { :total_unfiltered_queries => 0, :total_queries => 0, :total_clicks => 0, :last_month_total_queries => 0, :last_year_total_queries => 0 }
    @affiliate_stats.each_value do |affiliate_stats|
      @total_stats[:total_unfiltered_queries] += affiliate_stats[:total_unfiltered_queries]
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