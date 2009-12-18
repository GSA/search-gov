class AffiliatesController < ApplicationController
  layout "account"
  before_filter :require_affiliate, :except=> [:index]

  def index
  end

  def edit
  end

  def update
    @affiliate.attributes = params[:affiliate]
    if @affiliate.save
      @affiliate.update_attribute(:has_staged_content, true)
      flash[:success]= "Staged changes to your affiliate successfully."
      redirect_to account_path
    else
      render :action => :edit
    end
  end

  def push_content_for
    @affiliate.update_attributes(:has_staged_content=> false,
                                 :domains => @affiliate.staged_domains,
                                 :header => @affiliate.staged_header,
                                 :footer => @affiliate.staged_footer)
    flash[:success] = "Staged content is now visible"
    redirect_to account_path
  end

  private
  def require_affiliate
    return false if require_user == false
    unless current_user.is_affiliate?
      redirect_to home_page_url
      return false
    end
    @affiliate = @current_user.affiliates.find params[:id]
    unless @affiliate
      redirect_to home_page_url
      return false
    end
  end

end
