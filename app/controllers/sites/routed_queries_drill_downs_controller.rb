class Sites::RoutedQueriesDrillDownsController < Sites::SetupSiteController
  def show
    @routed_queries_drill_down = SearchModuleDrillDown.new(@site, 'QRTD')
  end
end
