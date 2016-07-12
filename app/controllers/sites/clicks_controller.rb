class Sites::ClicksController < Sites::AnalyticsController
  def new
    @clicks_request = RtuClicksRequest.new(site: @site,
                                           filter_bots:
                                           @current_user.sees_filtered_totals?,
                                           start_date: @analytics_settings[:start],
                                           end_date: @analytics_settings[:end])
    @clicks_request.save
  end

  def create
    clicks_request_params = params[:rtu_clicks_request].merge(site: @site, filter_bots: @current_user.sees_filtered_totals?)
    @clicks_request = RtuClicksRequest.new(clicks_request_params)
    @clicks_request.save
    set_analytics_range(@clicks_request.start_date, @clicks_request.end_date)
    render :new
  end
end
