class Sites::I14yApiInstructionsController < Sites::SetupSiteController
  before_action :require_i14y_drawers

  def show
  end

  def require_i14y_drawers
    redirect_to site_path(@site) unless @site.gets_i14y_results?
  end
end
