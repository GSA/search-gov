class Analytics::AnalyticsAdminController < SslController
  helper :all
  layout "analytics"
  before_filter :require_analyst_admin

  private

  def require_analyst_admin
    return false if require_user == false
    unless current_user.is_analyst_admin?
      redirect_to home_page_url
      return false
    end
  end

  def default_url_options(options={})
    {}
  end
end