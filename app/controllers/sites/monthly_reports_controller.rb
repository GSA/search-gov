class Sites::MonthlyReportsController < Sites::SetupSiteController
  before_filter :establish_aws_connection

  def show
    month, year = (params[:mmyyyy] || Date.yesterday.strftime('%m/%Y')).split('/')
    @monthly_report = monthly_report(month, year)
  rescue ArgumentError => e
    month, year = Date.yesterday.strftime('%m/%Y').split('/')
    @monthly_report = monthly_report(month, year)
  end

  private
  def monthly_report(month, year)
    params[:rtu].present? ? RtuMonthlyReport.new(@site, year, month) : MonthlyReport.new(@site, year, month)
  end
end
