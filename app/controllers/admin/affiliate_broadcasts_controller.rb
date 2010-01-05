class Admin::AffiliateBroadcastsController < Admin::AdminController

  def new
    @affiliate_broadcast = AffiliateBroadcast.new
  end

  def create
    @affiliate_broadcast = AffiliateBroadcast.new(params[:affiliate_broadcast].merge(:user=>@current_user))
    if @affiliate_broadcast.save
      flash[:success] = "Message broadcasted to all affiliates successfully"
      redirect_to admin_affiliates_path
    else
      render :action => 'new'
    end
  end

end