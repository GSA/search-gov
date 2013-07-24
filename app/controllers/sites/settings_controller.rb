class Sites::SettingsController < Sites::BaseController
  before_filter :setup_site

  def edit
  end

  def update
    if @site.update_attributes site_params
      redirect_to edit_site_setting_path(@site), flash: { success: 'Your site settings have been updated.' }
    else
      render action: :edit
    end
  end

  private

  def site_params
    params[:site] ? params[:site].slice(:display_name) : {}
  end
end
