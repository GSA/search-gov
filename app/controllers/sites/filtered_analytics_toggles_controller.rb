class Sites::FilteredAnalyticsTogglesController < Sites::SetupSiteController
  ENABLED = "You're now filtering bot traffic. Analytics include likely humans only."
  DISABLED = "You're no longer filtering bot traffic. Analytics include both humans and bots."

  def create
    current_user.toggle! :sees_filtered_totals
    message = current_user.sees_filtered_totals? ? ENABLED : DISABLED
    redirect_to site_path(@site), flash: {success: message}
  end

end
