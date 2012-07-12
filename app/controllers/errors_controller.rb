class ErrorsController < ApplicationController
  before_filter :setup_affiliate
  has_mobile_fu
  before_filter :force_mobile_mode

  def page_not_found
    @page_title = I18n.t(:"page_not_found.title")
    @page_title << " - #{@affiliate.display_name}" if @affiliate
    respond_to do |format|
      format.html { render :layout => 'affiliate', :status => 404 }
      format.mobile { render :file => File.join(Rails.root, "public", "simple_404.html"), :status => 404 }
    end
  end

  private
  
  def setup_affiliate
    @affiliate = Affiliate.find_by_name(params[:name]) unless params[:name].blank?
    set_affiliate_based_on_locale_param
    set_locale_based_on_affiliate_locale
  end
end