class Admin::AffiliateBroadcastsController < Admin::AdminController
  PAGE_TITLE = "Affiliate Broadcast"

  def new
    @affiliate_broadcast = AffiliateBroadcast.new
    @page_title = PAGE_TITLE
  end

  def create
    @affiliate_broadcast = AffiliateBroadcast.new(params[:affiliate_broadcast].merge(:user=>@current_user))
    if @affiliate_broadcast.save
      flash[:success] = "Message broadcasted to all affiliates successfully"
      redirect_to admin_affiliates_path
    else
      @page_title = PAGE_TITLE
      render :action => 'new'
    end
  end

end
