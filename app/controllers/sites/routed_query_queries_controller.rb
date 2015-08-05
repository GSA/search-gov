class Sites::RoutedQueryQueriesController < Sites::SetupSiteController
  def show
    @routed_query = RoutedQuery.find_by_affiliate_id_and_id(@site.id, params[:model_id])
  end
end
