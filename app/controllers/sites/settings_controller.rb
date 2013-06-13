class Sites::SettingsController < Sites::BaseController
  before_filter :setup_affiliate

  def edit
  end

  def update
    if @affiliate.update_attributes affiliate_params
      redirect_to edit_site_setting_path(@affiliate), flash: { success: 'Your site settings have been updated.' }
    else
      render action: :edit
    end
  end

  private

  def affiliate_params
    params[:affiliate] ? params[:affiliate].slice(:display_name) : {}
  end
end
