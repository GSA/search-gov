class Sites::MonthlyReportsController < Sites::SetupSiteController

  def show
    month, year = (params[:mmyyyy] || default_mm_yyyy).split('/')
    @monthly_report = monthly_report(month, year)
  rescue ArgumentError => e
    Rails.logger.error e
    month, year = default_mm_yyyy.split('/')
    @monthly_report = monthly_report(month, year)
  end

  private

  def default_mm_yyyy
    Date.current.strftime('%m/%Y')
  end

  def monthly_report(month, year)
    RtuMonthlyReport.new(@site, year, month)
  end

end
