class Sites::ClicksController < Sites::SetupSiteController
  def new
    @clicks_request = RtuClicksRequest.new(site: @site, filter_bots: @current_user.sees_filtered_totals?)
    @clicks_request.save
  end

  def create
    clicks_request_params = params[:rtu_clicks_request].merge(site: @site, filter_bots: @current_user.sees_filtered_totals?)
    @clicks_request = RtuClicksRequest.new(clicks_request_params)
    @clicks_request.save
    render :new
  end
end
