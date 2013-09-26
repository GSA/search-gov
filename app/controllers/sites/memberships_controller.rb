class Sites::MembershipsController < Sites::SetupSiteController

  def update
    membership = @site.memberships.find_by_id params[:id]
    membership.toggle! :gets_daily_snapshot_email
    verb = membership.gets_daily_snapshot_email? ? 'enabled' : 'disabled'
    redirect_to site_path(@site), flash: {success: "You have #{verb} the daily snapshot setting for #{@site.name}."}
  end

end
