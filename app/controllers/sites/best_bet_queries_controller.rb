class Sites::BestBetQueriesController < Sites::SetupSiteController
  def show
    klass = BestBetType.get_klass params[:module_tag]
    @best_bet = klass.find_by_affiliate_id_and_id(@site.id, params[:model_id]) if klass
  end
end
