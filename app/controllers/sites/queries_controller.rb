class Sites::QueriesController < Sites::SetupSiteController
  def new
    @queries_request = QueriesRequest.new(site: @site)
    @queries_request.save
  end

  def create
    @queries_request = QueriesRequest.new(params[:queries_request].merge(site: @site))
    @queries_request.save
    render :new
  end
end
