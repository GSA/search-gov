class Sites::BestBetsDrillDownsController < Sites::SetupSiteController
  def show
    @best_bets_drill_down = BestBetsDrillDown.new(@site, params[:module_tag])
  end
end
