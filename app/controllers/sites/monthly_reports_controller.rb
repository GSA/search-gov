class Sites::MonthlyReportsController < Sites::SetupSiteController

  def show
    month, year = (params[:mmyyyy] || default_mm_yyyy).split('/')
    @monthly_report = monthly_report(month, year)
  rescue ArgumentError => e
    month, year = default_mm_yyyy.split('/')
    @monthly_report = monthly_report(month, year)
  end

  private

  def default_mm_yyyy
    Date.current.strftime('%m/%Y')
  end

  def monthly_report(month, year)
    if Date.civil(year.to_i, month.to_i) < Date.parse(RtuDashboard::RTU_START_DATE)
      establish_aws_connection
      MonthlyReport.new(@site, year, month)
    else
      RtuMonthlyReport.new(@site, year, month, @current_user.sees_filtered_totals?)
    end
  end

  def establish_aws_connection
    AWS::S3::Base.establish_connection!(:access_key_id => AWS_ACCESS_KEY_ID, :secret_access_key => AWS_SECRET_ACCESS_KEY)
  end

end
