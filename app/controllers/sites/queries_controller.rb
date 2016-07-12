class Sites::QueriesController < Sites::AnalyticsController
  def new
    @queries_request = RtuQueriesRequest.new(site: @site,
                                             filter_bots: @current_user.sees_filtered_totals?,
                                             start_date: @analytics_settings[:start],
                                             end_date: @analytics_settings[:end])
    @queries_request.save
  end

  def create
    queries_request_params = params[:rtu_queries_request].merge(site: @site, filter_bots: @current_user.sees_filtered_totals?)
    @queries_request = RtuQueriesRequest.new(queries_request_params)
    @queries_request.save
    set_analytics_range(@queries_request.start_date, @queries_request.end_date)
    render :new
  end
end
