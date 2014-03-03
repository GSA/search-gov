class Sites::MonthlyReportsController < Sites::SetupSiteController

  def show
    month, year = (params[:mmyyyy] || Date.yesterday.strftime('%m/%Y')).split('/')
    @monthly_report = MonthlyReport.new(@site, year, month)
  rescue ArgumentError => e
    month, year = Date.yesterday.strftime('%m/%Y').split('/')
    @monthly_report = MonthlyReport.new(@site, year, month)
  end
end
