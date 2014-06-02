class Sites::MonthlyReportsController < Sites::SetupSiteController
  before_filter :establish_aws_connection

  def show
    month, year = (params[:mmyyyy] || default_mm_yyyy).split('/')
    @monthly_report = monthly_report(month, year)
  rescue ArgumentError => e
    month, year = default_mm_yyyy.split('/')
    @monthly_report = monthly_report(month, year)
  end

  private

  def default_mm_yyyy
    date = params[:rtu].present? ? Date.current : Date.yesterday
    date.strftime('%m/%Y')
  end

  def monthly_report(month, year)
    params[:rtu].present? ? RtuMonthlyReport.new(@site, year, month) : MonthlyReport.new(@site, year, month)
  end
end
