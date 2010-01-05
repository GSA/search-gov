class Analytics::AnalyticsController < ActionController::Base
  layout "analytics"
  helper :all
  before_filter :check_access if Rails.env == "production"

  private
  def check_access
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == "analytics" && password == "4n4lyt1cs"
    end
  end
end