class Sites::ReferrersController < Sites::AnalyticsController
  def new
    @referrers_request = RtuReferrersRequest.new(site: @site,
                                                 start_date: @analytics_settings[:start],
                                                 end_date: @analytics_settings[:end])
    @referrers_request.save
  end

  def create
    @referrers_request = RtuReferrersRequest.new(referrers_request_params)
    @referrers_request.save
    set_analytics_range(@referrers_request.start_date, @referrers_request.end_date)
    render :new
  end

  private

  def referrers_request_params
    params[:rtu_referrers_request].permit(
      :start_date,
      :end_date,
      :range
    ).merge(
      site: @site
    ).to_h
  end
end
