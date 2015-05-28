class Sites::I14yApiInstructionsController < Sites::SetupSiteController
  before_filter :require_i14y_drawers

  def show
  end

  def require_i14y_drawers
    redirect_to site_path(@site) unless @site.i14y_drawers.present?
  end
end
