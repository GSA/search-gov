class Sites::AlertsController < Sites::SetupSiteController
  before_action :setup_site
  before_action :setup_alert

  def edit
  end

  def create
    update
  end

  def update
    if @alert.update_attributes(site_alert_params)
      redirect_to edit_site_alert_path(@site), flash: { success: 'The alert for this site has been updated.' }
    else
      render action: :edit
    end
  end

  private

  def setup_alert
    @alert = @site.alert || @site.build_alert
  end

  def site_alert_params
    @site_alert_params ||= params.require(:alert).permit(:text, :status, :title).to_h
  end
end
