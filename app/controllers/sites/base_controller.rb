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

  def setup_affiliate
    affiliate_id = params[:site_id] || params[:id]
    if current_user.is_affiliate_admin?
      @affiliate = Affiliate.find(affiliate_id)
    elsif current_user.is_affiliate?
      @affiliate = current_user.affiliates.find(affiliate_id) rescue redirect_to(home_affiliates_path) and return false
    end
    true
  end

  def setup_help_link
    help_link_key = HelpLink.sanitize_request_path(request.fullpath)
    @help_link = HelpLink.find_by_request_path(help_link_key)
  end

  def default_url_options
    {}
  end
end
