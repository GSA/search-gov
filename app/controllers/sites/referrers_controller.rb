class Sites::ReferrersController < Sites::AnalyticsController
  def new
    @referrers_request = RtuReferrersRequest.new(site: @site, filter_bots: @current_user.sees_filtered_totals?)
    @referrers_request.save
  end

  def create
    referrers_request_params = params[:rtu_referrers_request].merge(site: @site, filter_bots: @current_user.sees_filtered_totals?)
    @referrers_request = RtuReferrersRequest.new(referrers_request_params)
    @referrers_request.save
    set_analytics_range(@referrers_request.start_date, @referrers_request.end_date)
    render :new
  end
end
