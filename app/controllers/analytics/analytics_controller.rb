class Analytics::AnalyticsController < SslController
  helper :all
  layout "analytics"
  before_filter :require_analyst

  private

  def require_analyst
    return false if require_user == false
    unless current_user.is_analyst?
      redirect_to home_page_url
      return false
    end
  end

  def default_url_options(options={})
    {}
  end
end