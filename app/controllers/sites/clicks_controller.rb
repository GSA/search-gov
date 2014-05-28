class Sites::ClicksController < Sites::SetupSiteController
  def new
    @clicks_request = params[:rtu].present? ? RtuClicksRequest.new(site: @site) : ClicksRequest.new(site: @site)
    @clicks_request.save
  end

  def create
    clicks_request_params = params[:rtu_clicks_request].present? ? params[:rtu_clicks_request].merge(site: @site) : params[:clicks_request].merge(site: @site)
    @clicks_request = params[:rtu].present? ? RtuClicksRequest.new(clicks_request_params) : ClicksRequest.new(clicks_request_params)
    @clicks_request.save
    render :new
  end
end
