class Analytics::MonthlyReportsController < Analytics::AnalyticsController
  before_filter :set_report_date, :establish_aws_connection

  def index
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month)
    @clicks = Click.monthly_totals_by_module(@report_date.year, @report_date.month)
  end

  private

  def set_report_date
    @today = Date.today
    @report_date = params[:date].blank? ? @today : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
  end
end