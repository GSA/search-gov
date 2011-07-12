class ErrorsController < ApplicationController
  before_filter :setup_affiliate
  has_mobile_fu

  def page_not_found
    @page_title = I18n.t(:"page_not_found.title")
    @page_title << " - #{@affiliate.display_name}" if @affiliate
    respond_to do |format|
      format.html do
        render :layout => 'application', :status => 404 unless @affiliate
        render :layout => 'affiliate', :status => 404 if @affiliate
      end
      format.mobile { render :file => File.join(Rails.root, "public", "simple_404.html"), :status => 404 }
    end
  end

  def setup_affiliate
    @affiliate = Affiliate.find_by_name(params[:name]) unless params[:name].blank?
    if @affiliate && params[:staged]
      @affiliate.header = @affiliate.staged_header
      @affiliate.footer = @affiliate.staged_footer
      @affiliate.affiliate_template_id = @affiliate.staged_affiliate_template_id
    end
  end
end
