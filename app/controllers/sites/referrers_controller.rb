class Sites::ReferrersController < Sites::SetupSiteController
  def new
    @referrers_request = RtuReferrersRequest.new(site: @site, filter_bots: @current_user.sees_filtered_totals?)
    @referrers_request.save
  end

  def create
    referrers_request_params = params[:rtu_referrers_request].merge(site: @site, filter_bots: @current_user.sees_filtered_totals?)
    @referrers_request = RtuReferrersRequest.new(referrers_request_params)
    @referrers_request.save
    render :new
  end
end
