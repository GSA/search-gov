class AffiliatesController < ApplicationController
  layout "account"
  before_filter :require_affiliate, :except=> [:index]

  def index
  end

  def edit
    @affiliate = @current_user.affiliates.find params[:id]
  end

  def update
    @affiliate = @current_user.affiliates.find params[:id]
    @affiliate.attributes = params[:affiliate]
    if @affiliate.save
      flash[:success]= "Updated your affiliate successfully."
      redirect_to account_path
    else
      render :action => :edit
    end
  end

  private
  def require_affiliate
    return false if require_user == false
    unless current_user.is_affiliate?
      redirect_to home_page_url
      return false
    end
  end

end
