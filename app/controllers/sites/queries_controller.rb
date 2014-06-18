class Sites::QueriesController < Sites::SetupSiteController
  def new
    @queries_request = RtuQueriesRequest.new(site: @site, filter_bots: @current_user.sees_filtered_totals?)
    @queries_request.save
  end

  def create
    queries_request_params = params[:rtu_queries_request].merge(site: @site, filter_bots: @current_user.sees_filtered_totals?)
    @queries_request = RtuQueriesRequest.new(queries_request_params)
    @queries_request.save
    render :new
  end
end
