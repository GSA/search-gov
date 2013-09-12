class Sites::QueryClicksController < Sites::SetupSiteController
  def show
    @end_date = request["end_date"].to_date
    @start_date =  request["start_date"].to_date
    @query = request["query"]
    @top_urls = QueriesClicksStat.top_urls(@site.name, @query, @start_date, @end_date)
  end
end
