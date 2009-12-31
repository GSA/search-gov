class AffiliatesController < AffiliateAuthController
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
    @affiliate.update_attributes(
      :has_staged_content=> false,
      :domains => @affiliate.staged_domains,
      :header => @affiliate.staged_header,
      :footer => @affiliate.staged_footer)
    flash[:success] = "Staged content is now visible"
    redirect_to account_path
  end

end
