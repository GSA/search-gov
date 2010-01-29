class AffiliateAuthController < ApplicationController
  layout "account"

  private
  def require_affiliate
    return false if require_user == false
    unless current_user.is_affiliate?
      redirect_to home_page_url
      return false
    end
  end
  
  def setup_affiliate
    @affiliate = @current_user.affiliates.find(params[:id] || params[:affiliate_id]) rescue redirect_to(home_page_url) and return false
  end

end
