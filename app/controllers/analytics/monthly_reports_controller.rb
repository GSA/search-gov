class Analytics::MonthlyReportsController < Analytics::AnalyticsController
  before_filter :set_report_date, :establish_aws_connection

  def index
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month)
    @search_module_stats = DailySearchModuleStat.module_stats_for_daterange_and_affiliate_and_locale(@report_date.beginning_of_month..@report_date.end_of_month)
    @num_results_mpq = (request["num_results_mpq"] || "10").to_i
    @popular_queries_for_month = MonthlyPopularQuery.find_all_by_year_and_month_and_is_grouped(@report_date.year, @report_date.month, false, :order => "times DESC", :limit => @num_results_mpq)
    @num_results_mpqg = (request["num_results_mpqg"] || "10").to_i
    @popular_groups_for_month = MonthlyPopularQuery.find_all_by_year_and_month_and_is_grouped(@report_date.year, @report_date.month, true, :order => "times DESC", :limit => @num_results_mpqg)
  end

  private

  def set_report_date
    @most_recent_date = DailyUsageStat.most_recent_populated_date || Date.current
    @report_date = params[:date].blank? ? Date.yesterday : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
  end
end