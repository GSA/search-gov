class Affiliates::AffiliatesController < SslController
  newrelic_ignore
  before_filter :setup_help_link

  layout "account"

  protected

  def require_affiliate
    return false if require_user == false
    unless current_user.is_affiliate?
      redirect_to home_page_url
      false
    end
  end

  def require_affiliate_or_admin
    return false if require_user == false
    unless current_user.is_affiliate? || current_user.is_affiliate_admin?
      redirect_to home_page_url
      false
    end
  end

  def require_approved_user
    unless current_user.is_approved?
      if current_user.is_pending_email_verification?
        flash[:notice] = "Your email address has not been verified. Please check your inbox so we may verify your email address."
      elsif current_user.is_pending_approval?
        flash[:notice] = "Your account has not been approved. Please try again when you are set up."
      elsif current_user.is_pending_contact_information?
        flash[:notice] = "Your contact information is not complete."
      end
      redirect_to home_affiliates_path
      false
    end
  end

  def setup_affiliate
    affiliate_id = params[:affiliate_id] || params[:id]
    if current_user.is_affiliate_admin?
      @affiliate = Affiliate.find(affiliate_id)
    elsif current_user.is_affiliate?
      @affiliate = current_user.affiliates.find(affiliate_id) rescue redirect_to(home_page_url) and return false
    end
    true
  end

  def setup_help_link
    help_link_key = request.fullpath.split("/").last
    @help_link = HelpLink.find_by_action_name(help_link_key)
  end

  def default_url_options(options={})
    {}
  end
end
