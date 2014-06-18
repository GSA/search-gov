class Sites::AnalyticsSettingsController < Sites::SetupSiteController
  def edit
  end

  def update
    if @current_user.update_attributes(params[:user])
      flash.now[:success] = "You have updated your analytics settings."
    end
    render :edit
  end

end
