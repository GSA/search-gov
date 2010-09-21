class Analytics::MonthlyReportsController < Analytics::AnalyticsController
  before_filter :set_report_date, :establish_aws_connection

  def index
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month)
    @clicks = Click.monthly_totals_by_module(@report_date.year, @report_date.month)
    @num_results_mpq = (request["num_results_mpq"] || "10").to_i
    @popular_queries_for_month = DailyQueryStat.most_popular_terms_for_year_month(@report_date.year, @report_date.month, @num_results_mpq)
    @num_results_mpqg = (request["num_results_mpq_mpqg"] || "10").to_i
    @popular_groups_for_month = DailyQueryStat.most_popular_groups_for_year_month(@report_date.year, @report_date.month, @num_results_mpqg)
  end

  private

  def set_report_date
    @today = Date.today
    @report_date = params[:date].blank? ? @today : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
  end
end