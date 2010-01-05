class Admin::AdminController < ApplicationController
  layout "admin"
  before_filter :require_affiliate_admin

  private

  def require_affiliate_admin
    return false if require_user == false
    unless current_user.is_affiliate_admin?
      redirect_to home_page_url
      return false
    end
  end

  def default_url_options(options={})
    {}
  end
end