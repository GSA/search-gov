class Sites::BaseController < ApplicationController
  newrelic_ignore
  layout 'sites'

  before_filter :require_login
  before_filter :require_approved_user

  protected

  def require_login
    unless current_user
      store_location
      redirect_to login_url
    end
  end

  def require_approved_user
    unless current_user.is_approved?
      if current_user.is_pending_approval?
        flash[:notice] = 'Your account has not been approved. Please try again when you are set up.'
      end
      redirect_to account_path
    end
  end

  def setup_site
    site_id = params[:site_id] || params[:id]
    if current_user.is_affiliate_admin?
      @site = Affiliate.find(site_id) rescue redirect_to(sites_path)
    elsif current_user.is_affiliate?
      @site = current_user.affiliates.active.find(site_id) rescue redirect_to(sites_path)
    end
  end
end
