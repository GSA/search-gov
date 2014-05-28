class Sites::QueriesController < Sites::SetupSiteController
  def new
    @queries_request = params[:rtu].present? ? RtuQueriesRequest.new(site: @site) : QueriesRequest.new(site: @site)
    @queries_request.save
  end

  def create
    queries_request_params = params[:rtu_queries_request].present? ? params[:rtu_queries_request].merge(site: @site) : params[:queries_request].merge(site: @site)
    @queries_request = params[:rtu_queries_request].present? ? RtuQueriesRequest.new(queries_request_params) : QueriesRequest.new(queries_request_params)
    @queries_request.save
    render :new
  end
end
