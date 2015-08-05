class Sites::BestBetsDrillDownsController < Sites::SetupSiteController
  def show
    @best_bets_drill_down = SearchModuleDrillDown.new(@site, params[:module_tag])
  end
end
