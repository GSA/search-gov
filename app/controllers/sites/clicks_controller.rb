class Sites::ClicksController < Sites::SetupSiteController
  def new
    @clicks_request = ClicksRequest.new(site: @site)
    @clicks_request.save
  end

  def create
    @clicks_request = ClicksRequest.new(params[:clicks_request].merge(site: @site))
    @clicks_request.save
    render :new
  end
end
