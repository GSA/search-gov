class Sites::BaseController < SslController
  newrelic_ignore
  layout 'sites'

  before_filter :require_login
  before_filter :require_approved_user

  protected

  def require_login
    unless current_user
      store_location
      redirect_to login_url
      false
    end
  end

  def require_approved_user
    unless current_user.is_approved?
      if current_user.is_pending_email_verification?
        flash[:notice] = 'Your email address has not been verified. Please check your inbox so we may verify your email address.'
      elsif current_user.is_pending_approval?
        flash[:notice] = 'Your account has not been approved. Please try again when you are set up.'
      elsif current_user.is_pending_contact_information?
        flash[:notice] = 'Your contact information is not complete.'
      end
      redirect_to home_affiliates_path
      false
    end
  end

  def setup_site
    site_id = params[:site_id] || params[:id]
    if current_user.is_affiliate_admin?
      @site = Affiliate.find(site_id)
    elsif current_user.is_affiliate?
      @site = current_user.affiliates.find(site_id) rescue redirect_to(home_affiliates_path) and return false
    end
    true
  end

  def default_url_options
    {}
  end
end
