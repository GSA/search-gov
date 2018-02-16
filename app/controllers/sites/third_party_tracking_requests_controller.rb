class Sites::ThirdPartyTrackingRequestsController < Sites::SetupSiteController

  def new
  end

  def create
    if params[:submitted_external_tracking_code].present?
      @site.update_attribute(:submitted_external_tracking_code, params[:submitted_external_tracking_code])
      Emailer.update_external_tracking_code(@site, current_user, params[:submitted_external_tracking_code]).deliver_now
      redirect_to site_path(@site), flash: { success: 'Your request to update your web analytics code has been submitted.' }
    else
      flash.now[:error] = "Web analytics JavaScript code can't be blank"
      render action: :new
    end
  end
end
